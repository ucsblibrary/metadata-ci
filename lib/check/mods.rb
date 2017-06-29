# frozen_string_literal: true

require "net/http"
require File.expand_path("../../errors/invalid_mods.rb", __FILE__)
require File.expand_path("../../errors/wrong_encoding.rb", __FILE__)

module Check
  # Checks that MODS XML files follow the schema
  module MODS
    # @param [String, Array<String>] files
    # @return [Array<EncodedEntity>]
    def self.batch(*files)
      files.flatten.map do |file|
        next unless File.extname(file) == ".xml"

        validate(file)
      end.flatten.compact.select { |r| r.is_a? InvalidMODS }
    end

    # @param [URL, String] url
    # @return [Nokogiri::XML::Schema]
    def self.schema_from_url(url)
      Nokogiri::XML::Schema(
        Net::HTTP.get(
          (url.is_a?(URI) ? url : URI(url))
        )
      )
    end

    # @param [String] file
    # @return [Array<MetadataError>]
    def self.validate(file)
      xml = Nokogiri::XML(File.read(file))
      schema = xml
        .xpath("mods:mods")
        .first
        .attributes["schemaLocation"]
        .text
        .split(" ")
        .last

      schema_from_url(schema).validate(xml).map do |error|
        InvalidMODS.new(file: file, problem: error.to_s)
      end
    # most likely an encoding error
    rescue ArgumentError => e
      [WrongEncoding.new(file: file, problem: e.message)]
    end
  end
end
