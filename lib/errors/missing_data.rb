# frozen_string_literal: true

require File.expand_path("../metadata_error.rb", __FILE__)

# Used by {Check::DataSources} to warn when a metadata file specifies
# a path to a non-existent data source
class MissingData < MetadataError; end
