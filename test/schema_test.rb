# frozen_string_literal: true

require "minitest/autorun"
require File.expand_path("../lib/metadata_ci.rb", __dir__)

class SchemaTest < MiniTest::Test
  def test_csv_files
    assert_empty(
      Check::Schema.batch(
        [File.expand_path("fixtures/csv/pamss045-invalid.csv", __dir__),
         File.expand_path("fixtures/csv/pamss045.csv", __dir__),]
      )
    )
  end

  def test_good_mods
    assert_empty(
      Check::Schema.batch(
        [File.expand_path("fixtures/mods/cusbmss228-p00001-invalid.xml",
                          __dir__),
         File.expand_path("fixtures/mods/cusbmss228-p00001-latin1.xml",
                          __dir__),
         File.expand_path(
           "fixtures/mods/cusbmss228-p00001-missing-declaration.xml",
           __dir__
         ),]
      )
    )
  end

  def test_bad_mods
    errors = Check::Schema.batch(
      [File.expand_path("fixtures/mods/cusbmss228-p00001.xml", __dir__),
       File.expand_path("fixtures/mods/cusbspcmss36-110001-ISO-8859-1.xml",
                        __dir__),
       File.expand_path("fixtures/mods/cusbspcmss36-110001_utf16.xml",
                        __dir__),
       File.expand_path("fixtures/mods/cusbspcmss36-110001_windows-1252.xml",
                        __dir__),
       File.expand_path("fixtures/mods/html-entities.xml", __dir__),]
    )

    refute_empty errors
    assert_equal 12, errors.count
  end
end
