# frozen_string_literal: true

require File.expand_path("../../errors/wrong_encoding.rb", __FILE__)

module Check
  module Encoding
    def self.about
      "Metadata files should be encoded as UTF-8."
    end

    # @param [String] file Path to the file
    # @param [Encoding]
    def self.is?(file, encoding = ::Encoding::UTF_8)
      raw = File.read(file)
      # calling #split will trigger invalid byte errors:
      # https://robots.thoughtbot.com/fight-back-utf-8-invalid-byte-sequences
      raw.split(" ")

      check_for_declaration(file, raw)
      return true if raw.encoding == encoding

      raise WrongEncoding.new(file: file,
                              problem: "Expected #{encoding.name}, "\
                                       "got #{raw.encoding.name}")
    rescue ArgumentError => e
      raise WrongEncoding.new(file: file, problem: e.message)
    end

    # @return [Nil]
    def self.check_for_declaration(filename, contents)
      return unless File.extname(filename) == ".xml" &&
                    !contents.downcase.include?('encoding="utf-8"')

      raise(
        WrongEncoding.new(file: filename,
                          problem: "Missing 'encoding=\"UTF-8\"' declaration.")
      )
    end

    # @param [Array<String>] files
    # @return [Array<WrongEncoding>]
    def self.batch(files)
      files.map do |f|
        begin
          is?(f)
        rescue WrongEncoding => e
          e
        end
      end.select { |result| result.is_a? WrongEncoding }
    end
  end
end
