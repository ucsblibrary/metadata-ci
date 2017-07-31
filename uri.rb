# frozen_string_literal: true

require 'uri'

# Methods for URI checking
module Fields::URI
  # @param [String] str
  def self.looks_like_uri?(str)
    str =~ %r{^https?:\/\/}
  end

  # Given a row of data from a spreadsheet, check that all the URIs
  # are well formed If we wait until we create the object to detect
  # errors, it's much more difficult to raise a helpful error message.
  #
  # @param [String] str
  def self.check_uri(str)
    return if str.nil? || looks_like_uri?(str)
    return if str.strip =~ /\A#{::URI.regexp}\z/

    raise ArgumentError, "Invalid URI: #{str}"
  end
end
