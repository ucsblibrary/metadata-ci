# frozen_string_literal: true

module Fields
  module MODS
    # @param [Mods::Record] mods
    # @return [Hash]
    def self.resource_type(mods)
      if collection?(mods)
        # This ensures that MODS Collections have their work_type be
        # Collection /and/ all the formats of the items they contain
        RESOURCE_MAP['collection'].merge(
          uri: [
            RESOURCE_MAP['collection'][:uri],
            *mods.typeOfResource.content.map { |t| RESOURCE_MAP[t][:uri] }
          ].flatten
        )
      else
        # return an empty hash in the case of XML fragments
        RESOURCE_MAP[mods.typeOfResource.content.first] || {}
      end
    end

    # @param [Mods::Record] mods
    def self.model(mods)
      return 'Collection' if collection?(mods)

      case mods.typeOfResource.content.first
      when *ETD_TYPES
        'ETD'
      when *AUDIO_TYPES
        'AudioRecording'
      when *IMAGE_TYPES
        'Image'
      else
        raise ArgumentError,
              "Unsupported work type #{mods.typeOfResource.content.first}"
      end
    end

    # This is more complicated than other object types because a
    # collection will also specify the types of the objects within it
    #
    # @param [Mods::Record] mods
    def self.collection?(mods)
      type_keys = mods.typeOfResource.attributes.map(&:keys).flatten
      return false unless type_keys.include?('collection')

      mods.typeOfResource.attributes.any? do |hash|
        hash.fetch('collection').value == 'yes'
      end
    end

    AUDIO_TYPES = [
      'sound recording-musical',
      'sound recording-nonmusical'
    ].freeze
    ETD_TYPES = %w[text].freeze
    IMAGE_TYPES = ['still image'].freeze

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
