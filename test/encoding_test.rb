# frozen_string_literal: true

require "minitest/autorun"
require File.expand_path("../lib/metadata_ci.rb", __dir__)

class EncodingTest < MiniTest::Test
  def test_good_encodings
    assert_empty(
      Check::Encoding.batch(
        [File.expand_path("fixtures/csv/pamss045-invalid.csv", __dir__),
         File.expand_path("fixtures/csv/pamss045.csv", __dir__),
         File.expand_path("fixtures/mods/cusbmss228-p00001-invalid.xml",
                          __dir__),
         File.expand_path("fixtures/mods/cusbmss228-p00001.xml",
                          __dir__),]
      )
    )
  end

  def test_weird_utf8_csv
    errors = Check::Encoding.batch(
      [File.expand_path("fixtures/csv/mcpeak-utf8problems.csv", __dir__),
       File.expand_path("fixtures/csv/uarch112-part3a-excel-csv.csv",
                        __dir__),
       File.expand_path("fixtures/csv/uarch112-part3a-msdos-csv.csv",
                        __dir__),
       File.expand_path("fixtures/csv/uarch112-part3a-windows-csv.csv",
                        __dir__),]
    )

    refute_empty errors
    assert_equal 4, errors.count
  end

  def test_weird_utf8_mods
    errors = Check::Encoding.batch(
      [File.expand_path("fixtures/mods/cusbspcmss36-110001-ISO-8859-1.xml",
                        __dir__),
       File.expand_path("fixtures/mods/cusbspcmss36-110001_utf16.xml",
                        __dir__),
       File.expand_path("fixtures/mods/cusbspcmss36-110001_windows-1252.xml",
                        __dir__),]
    )

    refute_empty errors
    assert_equal 3, errors.count
  end

  def test_latin_encoding
    assert_raises WrongEncoding do
      Check::Encoding.is?(
        File.expand_path(
          "fixtures/mods/cusbmss228-p00001-latin1.xml",
          __dir__
        )
      )
    end
  end

  def test_missing_declaration
    assert_raises WrongEncoding do
      Check::Encoding.is?(
        File.expand_path(
          "fixtures/mods/cusbmss228-p00001-missing-declaration.xml",
          __dir__
        )
      )
    end
  end
end
