# frozen_string_literal: true

module Fields
  module MODS
    # Mapping of MODS typeOfResource to URIs
    # https://help.library.ucsb.edu/browse/DIGREPO-522
    # https://www.loc.gov/standards/mods/userguide/typeofresource.html
    RESOURCE_MAP = {
      'text' => {
        label: 'Text',
        uri: [RDF::URI.new('http://id.loc.gov/vocabulary/resourceTypes/txt')]
      },
      'cartographic' => {
        label: 'Cartographic',
        uri: [RDF::URI.new('http://id.loc.gov/vocabulary/resourceTypes/car')]
      },
      'notated music' => {
        label: 'Notated music',
        uri: [RDF::URI.new('http://id.loc.gov/vocabulary/resourceTypes/not')]
      },
      'sound recording-nonmusical' => {
        label: 'Audio non-musical',
        uri: [RDF::URI.new('http://id.loc.gov/vocabulary/resourceTypes/aun')]
      },
      'sound recording-musical' => {
        label: 'Audio musical',
        uri: [RDF::URI.new('http://id.loc.gov/vocabulary/resourceTypes/aum')]
      },
      'still image' => {
        label: 'Still image',
        uri: [RDF::URI.new('http://id.loc.gov/vocabulary/resourceTypes/img')]
      },
      'moving image' => {
        label: 'Moving image',
        uri: [RDF::URI.new('http://id.loc.gov/vocabulary/resourceTypes/mov')]
      },
      'three dimensional object' => {
        label: 'Artifact',
        uri: [RDF::URI.new('http://id.loc.gov/vocabulary/resourceTypes/art')]
      },
      'software, multimedia' => {
        label: 'Multimedia',
        uri: [RDF::URI.new('http://id.loc.gov/vocabulary/resourceTypes/mul')]
      },
      'mixed material' => {
        label: 'Mixed material',
        uri: [RDF::URI.new('http://id.loc.gov/vocabulary/resourceTypes/mix')]
      },
      'collection' => {
        label: 'Collection',
        uri: [RDF::URI.new('http://id.loc.gov/vocabulary/resourceTypes/col')]
      }
    }.freeze
  end
end
