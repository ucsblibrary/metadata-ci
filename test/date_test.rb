# frozen_string_literal: true

require "minitest/autorun"
require File.expand_path("../lib/metadata_ci.rb", __dir__)

class DateTest < MiniTest::Test
  def test_mods_fields
    refute_empty Check::Date.mods_fields
    assert(Check::Date.mods_fields.all? { |c| c.is_a? String })
  end

  def test_mods_checking
    assert_empty(
      Check::Date.mods(
        File.expand_path("fixtures/mods/cusbmss228-p00001.xml", __dir__)
      )
    )

    errors = Check::Date.mods(
      File.expand_path("fixtures/mods/cusbmss228-p00001-invalid.xml",
                       __dir__)
    )
    refute_empty errors
    assert_equal 1, errors.count
    assert(errors.all? { |e| e.is_a? InvalidDate })
  end

  def test_csv_columns
    refute_empty Check::Date.csv_columns
    assert(Check::Date.csv_columns.all? { |c| c.is_a? Symbol })
  end

  def test_csv_checking
    assert_empty(
      Check::Date.csv(
        File.expand_path("fixtures/csv/pamss045.csv", __dir__)
      )
    )

    errors = Check::Date.csv(
      File.expand_path("fixtures/csv/pamss045-invalid.csv", __dir__)
    )
    refute_empty errors
    assert_equal 3, errors.count
    assert(errors.all? { |e| e.is_a? InvalidDate })
  end

  def test_malformed_csv
    errors = Check::Date.csv(
      File.expand_path("fixtures/csv/mcpeak-utf8problems.csv", __dir__)
    )
    refute_empty errors
    assert_equal 1, errors.count
    assert(errors.all? { |e| e.is_a? WrongEncoding })
  end
end
