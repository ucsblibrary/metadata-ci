# frozen_string_literal: true

require "csv"
require "mods"
require File.expand_path("../../errors/missing_data.rb", __FILE__)
require File.expand_path("../../errors/wrong_encoding.rb", __FILE__)
require File.expand_path("../../util.rb", __FILE__)

module Check
  # Checks that the files specified in the metadata actually exist
  module DataSources
    DATA_SOURCES = YAML.safe_load(
      File.read(File.expand_path("../../../config/data_sources.yml", __FILE__))
    ).map { |d| Pathname.new(d) }

    # @param [Array<String>] files
    # @return [Array<MetadataError>]
    def self.batch(files)
      if DATA_SOURCES.all? { |ds| !Dir.exist? ds }
        warn "#{Util.warn("WARNING:")} "\
                     "None of the directories specified "\
                     "in config/data_sources.yml exist; skipping checks."
        return []
      end

      files.map do |file|
        paths_for(file).map do |path|
          next if DATA_SOURCES.any? do |ds|
            full_path = ds.join(path.sub(%r{^\/}, ""))
            full_path.exist? && !full_path.zero?
          end

          MissingData.new(
            file: file,
            problem: "#{path} doesn't exist in any of the "\
                     "data source directories (or is an empty file)."
          )
        end
      end.flatten.compact.select { |e| e.is_a? MetadataError }
    end

    # @param [String] file
    # @return [Array<String>]
    def self.paths_for(file)
      case File.extname(file)
      when ".xml"
        Mods::Record.new.from_file(
          file
        ).xpath("//mods:extension/fileName").map(&:text)
      when ".csv"
        CSV.table(file).map { |row| row[:files] }.compact
      else
        []
      end
    # most likely an encoding error
    rescue ArgumentError
      []
    end
  end
end
