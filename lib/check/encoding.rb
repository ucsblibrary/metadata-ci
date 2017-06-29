# frozen_string_literal: true

require File.expand_path("../../errors/wrong_encoding.rb", __FILE__)
require File.expand_path("../../util.rb", __FILE__)

module Check
  # Checks that files are encoded as UTF-8; see
  # https://help.library.ucsb.edu/browse/DIGREPO-683
  module Encoding
    # @param [String] file Path to the file
    # @param [Encoding]
    def self.is?(file, encoding = ::Encoding::UTF_8)
      raw = File.read(file)

      # calling #split will trigger invalid byte errors:
      # https://robots.thoughtbot.com/fight-back-utf-8-invalid-byte-sequences
      raw.split(" ")

      check_for_declaration(file, raw)
      return true if raw.encoding == encoding

      raise WrongEncoding,
            "#{Util.bold(file)}:\n  "\
            "Expected #{encoding.name}, got #{raw.encoding.name}"
    rescue ArgumentError => e
      raise WrongEncoding, "#{Util.bold(file)}:\n  #{e.message}"
    end

    def self.check_for_declaration(filename, contents)
      return unless File.extname(filename) == ".xml" &&
                    !contents.downcase.include?('encoding="utf-8"')

      raise WrongEncoding,
            "#{Util.bold(filename)}:\n  "\
            "Missing 'encoding=\"UTF-8\"' declaration."
    end

    # @param [Array<String>]
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
