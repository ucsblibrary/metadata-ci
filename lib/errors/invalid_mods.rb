# frozen_string_literal: true

require File.expand_path("../metadata_error.rb", __FILE__)

# Used by {Check::MODS} to warn when a MODS XML file does not follow
# the MODS schema: https://www.loc.gov/standards/mods/v3/
class InvalidMODS < MetadataError; end
