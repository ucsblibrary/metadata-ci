# frozen_string_literal: true

require "minitest/autorun"
require File.expand_path("../../lib/check.rb", __FILE__)

class CsvTest < MiniTest::Test
  def test_csv_columns
    refute_empty Check.csv_columns
    assert(Check.csv_columns.all? { |c| c.is_a? Symbol })
  end
end
