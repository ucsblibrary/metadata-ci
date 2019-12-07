# frozen_string_literal: true

require File.expand_path("metadata_error.rb", __dir__)

# Used by {Check::Entities} to flag HTML-encoded entities
class EncodedEntity < MetadataError; end
