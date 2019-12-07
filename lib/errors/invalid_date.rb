# frozen_string_literal: true

require File.expand_path("metadata_error.rb", __dir__)

# Used by {Check::Date} to determine if metadata date-strings are
# W3C-valid (https://www.w3.org/TR/1998/NOTE-datetime-19980827)
class InvalidDate < MetadataError; end
