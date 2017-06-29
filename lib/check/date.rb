# frozen_string_literal: true

require "csv"
require "date"
require "mods"
require "w3c_datetime"
require "yaml"
require File.expand_path("../../errors/invalid_date.rb", __FILE__)
require File.expand_path("../../errors/wrong_encoding.rb", __FILE__)

module Check
  # Provides methods for checking the W3C-validity of dates in CSV and
  # XML MODS metadata files
  module Date
    INVALID_DATE_MSG =
      "%<locator>s: '%<value>s' is not W3C-valid "\
      "(https://www.w3.org/TR/1998/NOTE-datetime-19980827)."

    # @param [Array<String>] files
    # @return [Array<MetadataError>]
    def self.batch(files)
      files.map do |file|
        case File.extname(file)
        when ".xml"
          mods(file)
        when ".csv"
          csv(file)
        else
          MetadataError.new(file: file,
                            problem: "Unsupported file type")
        end
      end.flatten
    end

    def self.date_fields
      @date_fields ||= YAML.safe_load(
        File.read(
          File.expand_path("../../../config/date_fields.yml", __FILE__)
        )
      )
    end

    # @return [Array<Symbol>]
    def self.csv_columns
      date_fields["csv"].map(&:to_sym)
    end

    # @param [String] file The path to the file
    # @return [Array<InvalidDate>]
    def self.csv(file)
      CSV.table(file, encoding: "bom|UTF-8").map.with_index do |row, i|
        csv_columns.map do |col|
          next if row[col].nil?

          validate(
            datestring: row[col].to_s,
            file: file,
            # add 2 to i since the CSV::Table doesn't have the headers
            # as a separate row, and the rows start from 0
            formatting: { locator: "#{col} on line #{i + 2}" }
          )
        end
      end.flatten.compact.select { |r| r.is_a? InvalidDate }
    # most likely an encoding error
    rescue ArgumentError => e
      [WrongEncoding.new(file: file, problem: e.message)]
    end

    # @return [Array<String>]
    def self.mods_fields
      date_fields["mods"]
    end

    # @param [String] file The path to the file
    # @return [Array<InvalidDate>]
    def self.mods(file)
      mod = Mods::Record.new.from_file(file)

      mods_fields.map do |field|
        dates = find_encoded_dates(mod, field, %w[w3cdtf iso8601])

        dates.map do |date|
          validate(datestring: date,
                   file: file,
                   formatting: { locator: "Value of #{field}" })
        end
      end.flatten.compact.select { |r| r.is_a? InvalidDate }
    end

    # @param [Mods::Record] document
    # @param [string] field
    # @param [Array] encodings
    # @return [Array<String>]
    def self.find_encoded_dates(document, field, encodings = [])
      document.origin_info.send(field).select do |d|
        encodings.include? d.encoding
      end.map(&:text).reject(&:empty?)
    rescue NoMethodError
      []
    end

    # @return [DateTime]
    def self.validate(datestring:, file:, formatting:)
      W3cDatetime.parse(datestring)
    rescue ArgumentError, InvalidDate
      InvalidDate.new(
        file: file,
        problem: format(
          INVALID_DATE_MSG,
          formatting.merge(value: datestring)
        )
      )
    end
  end
end
