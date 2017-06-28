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
    def self.batch(files)
      files.map do |file|
        case File.extname(file)
        when ".xml"
          mods(file)
        when ".csv"
          csv(file)
        else
          ArgumentError.new("#{file}: Unsupported file type")
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

          begin
            W3cDatetime.parse(row[col].to_s)
          rescue ArgumentError, InvalidDate
            InvalidDate.new(
              "#{file}:\n"\
              "  '#{col}' in row #{i}: "\
              "'\033[1;39m#{row[col]}\033[0m' is not W3C-valid "\
              "(https://www.w3.org/TR/1998/NOTE-datetime-19980827)."
            )
          end
        end
      end.flatten.compact.select { |r| r.is_a? InvalidDate }
    # most likely an encoding error
    rescue ArgumentError => e
      [WrongEncoding.new("#{file}: #{e.message}")]
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
        dates = begin
                  mod.origin_info.send(field).select do |d|
                    d.encoding == "w3cdtf" ||
                      d.encoding == "iso8601"
                  end.map(&:text).reject(&:empty?)
                rescue NoMethodError
                  []
                end

        next if dates.empty?

        dates.map do |date|
          begin
            W3cDatetime.parse(date)
          rescue ArgumentError, InvalidDate
            InvalidDate.new(
              "#{file}:\n"\
              "  Value of '\033[1;39m#{date}\033[0m' for '#{field}' "\
              "is not W3C-valid "\
              "(https://www.w3.org/TR/1998/NOTE-datetime-19980827)."
            )
          end
        end
      end.flatten.compact.select { |r| r.is_a? InvalidDate }
    end
  end
end
