# frozen_string_literal: true

require File.expand_path("../metadata_error.rb", __FILE__)

# Used by {Check::Headers} to signal an invalid header
class InvalidHeader < MetadataError; end
