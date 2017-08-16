# frozen_string_literal: true

require "charlock_holmes"
require File.expand_path("../../errors/wrong_encoding.rb", __FILE__)

module Check
  # Checks that files are encoded as UTF-8; see
  # https://help.library.ucsb.edu/browse/DIGREPO-683
  module Encoding
    # @param [String] file Path to the file
    # @param [Encoding]
    def self.validate_encoding(file, expected_encoding)
      raw = File.read(file)

      actual_encoding = CharlockHolmes::EncodingDetector.detect(raw)[:encoding]
      return if actual_encoding == expected_encoding.upcase

      WrongEncoding.new(
        file: file,
        problem: "Expected #{expected_encoding}, got #{actual_encoding}."
      )
    end

    # @return [Nil]
    def self.validate_declaration(file, expected_declaration)
      return unless File.extname(file) == ".xml"
      return if File.read(file)
                  .downcase
                  .include?("encoding=\"#{expected_declaration.downcase}\"")

      WrongEncoding.new(file: file,
                        problem: "Missing 'encoding=\"UTF-8\"' declaration.")
    rescue ArgumentError
    end

    # @param [Array<String>] files
    # @return [Array<WrongEncoding>]
    def self.batch(files)
      files.map do |f|
        [
          validate_encoding(f, "UTF-8"),
          validate_declaration(f, "UTF-8"),
        ]
      end.flatten.select { |result| result.is_a? WrongEncoding }
    end
  end
end
