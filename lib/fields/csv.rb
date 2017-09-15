# frozen_string_literal: true

require "yaml"
require "erb"
require File.expand_path("../marcrel.rb", __FILE__)

# CSV Header methods
module Fields::CSV
  # @return [Array]
  def self.all
    @all ||= YAML.safe_load(
      ::ERB.new(
        File.read(
          File.expand_path("../../../config/csv_headers.yml.erb", __FILE__)
        )
      ).result
    )
  end

  # All the permissible values for a CSV header cell
  #
  # @return [Array<String>]
  def self.all_fields
    @all_fields ||= all.map do |field|
      next field if field.is_a? String

      field.map do |key, val|
        next key unless val["subfields"]
        subfield_strings(val["subfields"])
      end
    end.flatten.compact
  end

  # All the CSV headers that have subfields
  #
  # @return [Array<Hash>]
  def self.all_subfields
    @all_subfields ||= all.map do |field|
      next unless field.respond_to? :values
      next unless field.values.first["subfields"]

      field
    end.compact
  end

  # All the CSV headers that have an order specified
  #
  # @return [Array<Hash>]
  def self.ordered_fields
    @ordered_fields ||= all.map do |field|
      next unless field.respond_to? :values
      next unless field.values.first["ordered"]

      field
    end.compact
  end

  # @param [Array] fields
  # @return [Array<String>]
  def self.subfield_strings(fields)
    fields.map do |s|
      next s unless s.respond_to? :keys
      s.keys
    end.flatten
  end
end
