# frozen_string_literal: true

require "htmlentities"
require File.expand_path("../../errors/encoded_entity.rb", __FILE__)

module Check
  # Checks for encoded HTML entities
  module Entities
    ENTITY_PATTERNS = {
      "0" => "&%<str>s;",
      "1" => "&#%<str>s;",
      "2" => "&#x%<str>s;",
    }.freeze

    # @param [String, Array<String>] files
    # @return [Array<EncodedEntity>]
    def self.batch(*files)
      decoder = HTMLEntities::Decoder.new("expanded")

      files.flatten.map do |file|
        lines = File.read(file, encoding: "bom|UTF-8").split("\n")

        lines.map.with_index do |line, i|
          matches = line.scan(decoder.send(:entity_regexp))
          next if matches.nil?

          matches.map do |match|
            # There are three types of HTML entities, so the match is
            # an Array with three elements, @see
            # https://github.com/threedaymonk/htmlentities/blob/master/lib/htmlentities/decoder.rb#L35
            match.map.with_index do |pattern, pos|
              next if pattern.nil?

              entity = format(ENTITY_PATTERNS[pos.to_s], str: pattern)

              EncodedEntity.new(
                "#{file}:\n  "\
                "HTML-encoded character '#{entity}' on line #{i + 1}"
              )
            end
          end
        end
      end.flatten.compact.select { |r| r.is_a? EncodedEntity }
    end
  end
end
