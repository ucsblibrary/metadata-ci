# frozen_string_literal: true

# Methods for transforming metadata fields
module Fields::Transformer
  def self.default
    @default ||= lambda do |header, value|
      if ::Fields::URI.looks_like_uri?(value.first)
        { header => [RDF::URI(value.first)] }
      else
        { header => value }
      end
    end
  end

  # @param [Proc] transformer
  def self.default=(transformer)
    @default = transformer
  end

  def self.single_valued(header, value)
    { header => value.first }
  end

  # @param [String] header
  # @param [Array<Hash>] values
  def self.collection(_header, values)
    subs = values.map do |v|
      parts = v.key.match(/^collection_(?<qualifier>.*)$/)
      next if parts.nil?

      val = if %w[admin_policy_id id].include? parts.named_captures[:qualifier]
              v.values.first
            else
              v.values
            end

      { v.key => val }
    end.reduce(&:merge)

    { collection: subs }
  end

  # @param [String] header
  # @param [Array<Hash>] values
  def self.subfields(header, values)
    subs = values.map do |v|
      parts = v.key.match(/^(?<name>[^_])_(?<qualifier>.*)$/)
      next if header_parts.nil?

      key = "#{parts.named_captures[:name]}_attributes".to_sym

      {
        key => {
          parts.named_captures[:qualifier] => v.values.flatten,
        },
      }
    end.reduce(&:merge)

    { header => subs }
  end

  def self.typed(header, value)
    {
      header =>
      [{
        type: header.to_s.sub(/_type$/, ""),
        name: value,
      },],
    }
  end
end
