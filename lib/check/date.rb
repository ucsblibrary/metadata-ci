# frozen_string_literal: true

require "csv"
require "date"
require "mods"
require "yaml"
require File.expand_path("../../errors/invalid_date.rb", __FILE__)
require File.expand_path("../../errors/wrong_encoding.rb", __FILE__)

module Check
  module Date
    def self.about
      "Date values should conform to the W3C format "\
      "(https://www.w3.org/TR/1998/NOTE-datetime-19980827)."
    end

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
        end
      end.flatten.compact
    end

    # TODO: replace with Fields::CSV
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
        validate_row_at(file, row, i)
      end.flatten.compact.select { |r| r.is_a? InvalidDate }
    # most likely an encoding error
    rescue ArgumentError => e
      [WrongEncoding.new(file: file, problem: e.message)]
    end

    # @param [String] file The path to the file
    # @param [CSV::Row] row
    # @param [Int] i
    # @return [Array<Nil, InvalidDate>
    def self.validate_row_at(file, row, i)
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
      parse_as_w3c(datestring)
    rescue ArgumentError, InvalidDate
      InvalidDate.new(
        file: file,
        problem: format(
          INVALID_DATE_MSG,
          formatting.merge(value: datestring)
        )
      )
    end

    W3REGEXP = /^
                 (?<year>\d{4})
                 (?<month>-?\d{2})?
                 (?<day>-?\d{2})?
                 (?<time>T?\d{2}:\d{2}:?\d{2}?\.?\d{2}?)?
                 (?<offset>Z|[-+]\d{2}:\d{2})?
               $/x

    # Parse date string in http://www.w3.org/TR/NOTE-datetime format
    #
    # @param [String] date_str date represented as string in
    #     http://www.w3.org/TR/NOTE-datetime format
    # @return [DateTime]
    def self.parse_as_w3c(date_str)
      matches = date_str.match(W3REGEXP)
      raise ArgumentError, "Bad string #{date_str}" if matches.nil?

      captures = matches.named_captures

      year = captures["year"].to_i
      month = (captures["month"].delete("-").to_i unless captures["month"].nil?)
      day = (captures["day"].delete("-").to_i unless captures["day"].nil?)
      times = parse_hms(captures["time"])

      params = [year, month, day, times, captures["offset"]].flatten.compact
      DateTime.new(*params)
    end

    def self.parse_hms(capturestring)
      return nil if capturestring.nil?

      times = capturestring.delete("T").split(":")

      hour = times.first.to_i
      minute = times[1].to_i
      second = (times[2].nil? ? 0 : times[2].to_f)

      [hour, minute, second]
    end
  end
end
