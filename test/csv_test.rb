# frozen_string_literal: true

require "minitest/autorun"
require File.expand_path("../../lib/date_checker.rb", __FILE__)

class CsvTest < MiniTest::Test
  def test_csv_columns
    refute_empty DateChecker.csv_columns
    assert(DateChecker.csv_columns.all? { |c| c.is_a? Symbol })
  end

  def test_csv_checking
    assert_empty(
      DateChecker.csv(File.expand_path("../fixtures/csv/pamss045.csv", __FILE__))
    )

    errors = DateChecker.csv(
      File.expand_path("../fixtures/csv/pamss045-invalid.csv", __FILE__)
    )
    refute_empty errors
    assert_equal 3, errors.count
    assert(errors.all? { |e| e.is_a? InvalidDate })
  end
end
