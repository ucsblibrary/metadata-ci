# frozen_string_literal: true

require "csv"
require "metadata-fields"
require File.expand_path("../../errors/invalid_header.rb", __FILE__)
require File.expand_path("../../errors/wrong_encoding.rb", __FILE__)

module Check
  # Checks that CSV files have valid headers
  module Headers
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

    # All the CSV headers that have subfields
    #
    # @return [Array<Hash>]
    def self.all_subfields
      @all_subfields ||= Fields::CSV.map do |field|
        next unless field.respond_to? :values
        next unless field.values.first["subfields"]

        field
      end.compact
    end

    # All the CSV headers that have an order specified
    #
    # @return [Array<Hash>]
    def self.ordered_fields
      @ordered_fields ||= Fields::CSV.map do |field|
        next unless field.respond_to? :values
        next unless field.values.first["ordered"]

        field
      end.compact
    end

    # All the permissible values for a CSV header cell
    #
    # @return [Array<String>]
    def self.all_fields
      @all_fields ||= Fields::CSV.map do |field|
        next field if field.is_a? String

        field.map do |key, val|
          next key unless val["subfields"]

          val["subfields"].map do |s|
            next s unless s.respond_to? :keys
            s.keys.first
          end
        end
      end.flatten.compact
    end

    # @param [String] file
    # @param [Array] headers
    # @return [Array<InvalidHeader>]
    def self.check_required_subfields(file, headers)
      all_subfields.map do |field|
        subs = field.values.first["subfields"]
        # If any of the subfields are used, then all their required
        # siblings need to be used
        next unless subs.map do |s|
          next s unless s.respond_to? :keys
          s.keys.first
        end.any? { |f| headers.map(&:to_s).include? f.to_s }

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
      ordered_fields.map do |field_group|
        subfields = field_group.values.first["subfields"]

        subfield_keys = subfields.map do |s|
          next s unless s.respond_to? :keys
          s.keys.first
        end

        next unless subfield_keys.any? do |k|
          headers.map(&:to_s).include? k.to_s
        end

        subfields.map.with_index do |sub, i|
          next unless headers.map(&:to_s).include? subfield_keys[i]
          next if subfield_keys[i + 1].nil?

          pointer = if sub.respond_to? :keys
                      sub.keys.first
                    else
                      sub
                    end

          header_i = headers.map(&:to_s).index(pointer)
          next if subfield_keys[i + 1] == headers.map(&:to_s)[header_i + 1]

          InvalidHeader.new(
            file: file,
            problem: "'#{sub.keys.first}' "\
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
        next if all_fields.include? header.to_s

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
      required = Fields::CSV.select do |header|
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
