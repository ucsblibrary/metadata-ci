# frozen_string_literal: true

require "minitest/autorun"
require File.expand_path("../../lib/check.rb", __FILE__)

class EncodingTest < MiniTest::Test
  def test_good_encodings
    assert_empty(
      Check::Encoding.batch(
        [File.expand_path("../fixtures/csv/pamss045-invalid.csv", __FILE__),
         File.expand_path("../fixtures/csv/pamss045.csv", __FILE__),
         File.expand_path("../fixtures/mods/cusbmss228-p00001-invalid.xml",
                          __FILE__),
         File.expand_path("../fixtures/mods/cusbmss228-p00001.xml",
                          __FILE__),]
      )
    )
  end

  def test_weird_utf8
    errors = Check::Encoding.batch(
      [File.expand_path("../fixtures/csv/mcpeak-utf8problems.csv", __FILE__),
       File.expand_path("../fixtures/csv/uarch112-part3a-excel-csv.csv",
                        __FILE__),
       File.expand_path("../fixtures/csv/uarch112-part3a-msdos-csv.csv",
                        __FILE__),
       File.expand_path("../fixtures/csv/uarch112-part3a-windows-csv.csv",
                        __FILE__),]
    )

    refute_empty errors
    assert_equal 4, errors.count
  end

  def test_latin_encoding
    assert_raises WrongEncoding do
      Check::Encoding.is?(
        File.expand_path(
          "../fixtures/mods/cusbmss228-p00001-latin1.xml",
          __FILE__
        )
      )
    end
  end

  def test_missing_declaration
    assert_raises WrongEncoding do
      Check::Encoding.is?(
        File.expand_path(
          "../fixtures/mods/cusbmss228-p00001-missing-declaration.xml",
          __FILE__
        )
      )
    end
  end
end
