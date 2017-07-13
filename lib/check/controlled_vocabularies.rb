# frozen_string_literal: true

require "csv"
require "metadata-fields"
require "mods"
require "yaml"
require File.expand_path("../../errors/wrong_encoding.rb", __FILE__)
require File.expand_path("../../errors/invalid_value.rb", __FILE__)

module Check
  # Checks that controlled fields only use allowed values
  module ControlledVocabularies
    ALLOWED_MODELS = YAML.safe_load(
      File.read(
        File.expand_path("../../../config/allowed_models.yml", __FILE__)
      )
    ).freeze

    ALLOWED_LOCATIONS = YAML.safe_load(
      File.read(
        File.expand_path("../../../config/allowed_locations.yml", __FILE__)
      )
    ).freeze

    # @param [Array<String>] files
    # @return [Array<MetadataError>]
    def self.batch(files)
      files.map do |file|
        validate_file(file)
      end.flatten.compact.select { |e| e.is_a? MetadataError }
    end

    # @param [String] file
    def self.objects_from_file(file)
      case File.extname(file)
      when ".xml"
        [Mods::Record.new.from_file(file)]
      when ".csv"
        CSV.table(file).map { |r| r }
      else
        []
      end
    end

    # @param [String] file
    def self.validate_file(file)
      objects_from_file(file).map do |obj|
        [
          validate_model(file, obj),
          validate_location(file, obj),
        ]
      end
    # most likely an encoding error
    rescue ArgumentError => e
      [WrongEncoding.new(file: file, problem: e.message)]
    end

    # @param [Mods::Record, CSV::Row] object
    # @return [String]
    def self.model(object)
      case object
      when Mods::Record
        begin
          Fields::MODS.model(object)
        rescue ArgumentError
          object.typeOfResource.content.first
        end
      when CSV::Row
        object[:type]
      else
        raise "Unsupported format #{object.class}"
      end
    end

    # @param [String] file
    # @param [Mods::Record, CSV::Row] object
    def self.validate_model(file, object)
      return if ALLOWED_MODELS.include? model(object)

      InvalidValue.new(
        file: file,
        problem: "'#{model(object)}' is not an allowed object type."
      )
    end

    # @param [Mods::Record, CSV::Row] object
    # @return [String]
    def self.location(object)
      case object
      when Mods::Record
        object.xpath("//mods:subLocation").text
      when CSV::Row
        object[:sub_location]
      else
        raise "Unsupported format #{object.class}"
      end
    end

    # @param [String] file
    # @param [Mods::Record, CSV::Row] object
    def self.validate_location(file, object)
      return if ALLOWED_LOCATIONS.include? location(object)

      InvalidValue.new(
        file: file,
        problem: "'#{location(object)}' is not an allowed location."
      )
    end
  end
end
