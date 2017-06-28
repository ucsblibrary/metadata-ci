# frozen_string_literal: true

require "minitest/autorun"
require File.expand_path("../../lib/check.rb", __FILE__)

class CsvTest < MiniTest::Test
  def test_csv_columns
    refute_empty Check::Date.csv_columns
    assert(Check::Date.csv_columns.all? { |c| c.is_a? Symbol })
  end

  def test_csv_checking
    assert_empty(
      Check::Date.csv(File.expand_path("../fixtures/csv/pamss045.csv", __FILE__))
    )

    errors = Check::Date.csv(
      File.expand_path("../fixtures/csv/pamss045-invalid.csv", __FILE__)
    )
    refute_empty errors
    assert_equal 3, errors.count
    assert(errors.all? { |e| e.is_a? InvalidDate })
  end

  def test_malformed_csv
    errors = Check::Date.csv(
      File.expand_path("../fixtures/csv/mcpeak-utf8problems.csv", __FILE__)
    )
    refute_empty errors
    assert_equal 1, errors.count
    assert(errors.all? { |e| e.is_a? WrongEncoding })
  end
end
