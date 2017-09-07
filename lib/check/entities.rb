# frozen_string_literal: true

require "htmlentities"
require File.expand_path("../../errors/encoded_entity.rb", __FILE__)
require File.expand_path("../../errors/wrong_encoding.rb", __FILE__)

module Check
  module Entities
    def self.about
      "Metadata files should not contain HTML-encoded entities."
    end

    ENTITY_PATTERNS = {
      "0" => "&%<str>s;",
      "1" => "&#%<str>s;",
      "2" => "&#x%<str>s;",
    }.freeze

    def self.whitelist
      @whitelist ||= YAML.safe_load(
        File.read(
          File.expand_path("../../../config/entity_whitelist.yml", __FILE__)
        )
      )
    end

    # @param [String] file
    # @param [Array<String>] matches
    # @return [Array<String>]
    def self.whitelisted_matches(file, matches)
      matches.reject do |match|
        ext = File.extname(file).delete(".")

        (whitelist[ext] || []).any? do |w|
          match.include? w
        end
      end
    end

    # @param [String, Array<String>] files
    # @return [Array<EncodedEntity>]
    def self.batch(*files)
      decoder = HTMLEntities::Decoder.new("expanded")

      files.flatten.map do |file|
        scan_file(file, decoder)
      end.flatten.compact.select { |r| r.is_a? EncodedEntity }
    end

    # @param [String] file
    # @param [HTMLEntities::Decoder] decoder
    # @return [Array<EncodedEntity>]
    def self.scan_file(file, decoder)
      File.read(file).split("\n").map.with_index do |line, i|
        matches = line.scan(decoder.send(:entity_regexp))
        next if matches.nil?

        whitelisted_matches(file, matches).map do |match|
          EncodedEntity.new(file: file,
                            problem: "HTML-encoded character "\
                                     "'#{format_match(match)}' "\
                                     "on line #{i + 1}.")
        end
      end
    # most likely an encoding error
    rescue ArgumentError => e
      [WrongEncoding.new(file: file, problem: e.message)]
    end

    # @param [Array] match
    # @return [String]
    def self.format_match(match)
      # There are three types of HTML entities, so the match is
      # an Array with three elements, two of them nil; @see
      # https://github.com/threedaymonk/htmlentities/blob/master/lib/htmlentities/decoder.rb#L35
      match.map.with_index do |pattern, pos|
        next if pattern.nil?

        break format(ENTITY_PATTERNS[pos.to_s], str: pattern)
      end
    end
  end
end
