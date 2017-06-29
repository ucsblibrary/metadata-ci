# frozen_string_literal: true

require File.expand_path("../../errors/invalid_mods.rb", __FILE__)
require File.expand_path("../../errors/wrong_encoding.rb", __FILE__)

module Check
  # Checks that MODS XML files follow the schema
  module MODS
    SCHEMA = File.read(
      File.expand_path("../../../schema/mods-3-6.xsd", __FILE__)
    )

    # @param [String, Array<String>] files
    # @return [Array<EncodedEntity>]
    def self.batch(*files)
      xsd = Nokogiri::XML::Schema(SCHEMA)

      files.flatten.map do |file|
        next unless File.extname(file) == ".xml"
        xml = Nokogiri::XML(File.read(file))

        xsd.validate(xml).map do |error|
          InvalidMODS.new(file: file, problem: error.to_s)
        end
      end.flatten.compact.select { |r| r.is_a? InvalidMODS }
    # most likely an encoding error
    rescue ArgumentError => e
      [WrongEncoding.new(file: file, problem: e.message)]
    end
  end
end
