# frozen_string_literal: true

require File.expand_path("../metadata_error.rb", __FILE__)

# Used by {Check::ControlledVocabulary} to warn when an invalid value
# is used for a controlled field
class InvalidValue < MetadataError; end
