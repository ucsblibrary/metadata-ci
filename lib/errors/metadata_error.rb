# frozen_string_literal: true

# Base error class for metadata errors
class MetadataError < StandardError
  attr_reader :file
  attr_reader :problem

  def initialize(file:, problem:)
    @file = file
    @problem = problem
  end
end
