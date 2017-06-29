# frozen_string_literal: true

require File.expand_path("../metadata_error.rb", __FILE__)

# Used by {Check::Encoding} to determine if metadata files are encoded
# correctly
class WrongEncoding < MetadataError; end
