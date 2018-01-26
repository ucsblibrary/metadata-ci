# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.authors  = ["Justin Coyne",
                   "Alex Dunn",
                   "Valerie Maher",]
  spec.files    = `git ls-files -z`.split("\x0")
  spec.homepage = "https://github.com/ucsblibrary/metadata-ci"
  spec.name     = "metadata_ci"
  spec.summary  = "Methods for automated metadata validation and processing."
  spec.version  = "0.0.1"

  spec.require_paths = ["lib"]

  spec.add_dependency "htmlentities"
  spec.add_dependency "mods"
  spec.add_dependency "nokogiri"
  spec.add_dependency "rdf-vocab", "< 3"
end
