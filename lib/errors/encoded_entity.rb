# frozen_string_literal: true

require File.expand_path("../metadata_error.rb", __FILE__)

# Used by {Check::Entities} to flag HTML-encoded entities
class EncodedEntity < MetadataError; end
