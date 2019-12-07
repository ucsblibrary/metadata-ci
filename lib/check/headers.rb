# frozen_string_literal: true

require "csv"

require File.expand_path("../errors/invalid_header.rb", __dir__)
require File.expand_path("../errors/wrong_encoding.rb", __dir__)
require File.expand_path("../fields.rb", __dir__)

module Check
  module Headers
    def self.about
      "CSV files should follow the specification in config/csv_headers.yml.erb."
    end

    # @param [String, Array<String>] files
    # @return [Array<InvalidHeader>]
    def self.batch(*files)
      files.flatten.map do |file|
        next unless File.extname(file) == ".csv"

        validate_headers(file)
      end.flatten.compact.select { |r| r.is_a? InvalidHeader }
    end

    # @param [String] file
    # @return [Array<MetadataError>]
    def self.validate_headers(file)
      headers = CSV.table(file, encoding: "bom|UTF-8").headers

      [
        check_required(file, headers),
        check_required_subfields(file, headers),
        check_undefined(file, headers),
        check_order(file, headers),
      ]
    # most likely an encoding error
    rescue ArgumentError => e
      [WrongEncoding.new(file: file, problem: e.message)]
    end

    # @param [String] file
    # @param [Array] headers
    # @return [Array<InvalidHeader>]
    def self.check_required_subfields(file, headers)
      Fields::CSV.all_subfields.map do |field|
        subs = field.values.first["subfields"]

        next unless Fields::CSV.subfield_strings(subs).any? do |f|
          headers.map(&:to_s).include? f.to_s
        end

        # If any of the subfields are used, then all their required
        # siblings need to be used
        required_siblings = subs.map do |sub|
          next unless sub.respond_to? :values
          next unless sub.values.any? { |v| v["required"] }

          sub.keys.first
        end.compact

        required_siblings.map do |rs|
          next if headers.map(&:to_s).include? rs.to_s

          InvalidHeader.new(
            file: file,
            problem: "All required '#{field.keys.first}' headers "\
                     "must be used (missing '#{rs}')."
          )
        end
      end.flatten.compact
    end

    def self.check_order(file, headers)
      # A field group will be something like
      #
      # { 'created' => {
      #     'ordered' => true,
      #     'subfields' => {
      #       'created_start' => { 'required' => true },
      #       'created_finish' => { 'required' => true },
      #       'created_label' => { 'required' => true },
      #       'created_start_qualifier' => { 'required' => true },
      #       'created_finish_qualifier' => { 'required' => true },
      #     },
      #   }, }
      Fields::CSV.ordered_fields.map do |field_group|
        subfield_keys = Fields::CSV.subfield_strings(
          field_group.values.first["subfields"]
        )

        next unless subfield_keys.any? do |k|
          headers.map(&:to_s).include? k.to_s
        end

        subfield_keys.map.with_index do |sub, i|
          next unless headers.map(&:to_s).include? subfield_keys[i]
          next if subfield_keys[i + 1].nil?

          header_i = headers.map(&:to_s).index(sub)
          next if subfield_keys[i + 1] == headers.map(&:to_s)[header_i + 1]

          InvalidHeader.new(
            file: file,
            problem: "'#{sub}' "\
                     "should be followed by '#{subfield_keys[i + 1]}'."
          )
        end
      end
    end

    # @param [String] file
    # @param [Array] headers
    # @return [Array<InvalidHeader>]
    def self.check_undefined(file, headers)
      headers.map do |header|
        next if Fields::CSV.all_fields.include? header.to_s

        InvalidHeader.new(
          file: file,
          problem: "'#{header}' is not an allowed header."
        )
      end
    end

    # @param [String] file
    # @param [Array] headers
    # @return [Array<InvalidHeader>]
    def self.check_required(file, headers)
      required = Fields::CSV.all.select do |header|
        next unless header.respond_to? :values

        header.values.first["required"]
      end.map(&:keys).flatten

      missing = required.reject do |r|
        headers.map(&:to_s).include? r.to_s
      end

      return if missing.empty?

      missing.map do |m|
        InvalidHeader.new(
          file: file,
          problem: "Missing required '#{m}' header."
        )
      end
    end
  end
end
