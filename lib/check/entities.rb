# frozen_string_literal: true

require "htmlentities"
require File.expand_path("../../errors/encoded_entity.rb", __FILE__)

module Check
  # Checks for encoded HTML entities
  module Entities
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
            EncodedEntity.new(
              "#{file}:\n  "\
              "HTML-encoded character '&#{match.first};' on line #{i + 1}"
            )
          end
        end
      end.flatten.compact.select { |r| r.is_a? EncodedEntity }
    end
  end
end
