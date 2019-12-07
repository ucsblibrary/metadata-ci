# frozen_string_literal: true

require "minitest/autorun"
require File.expand_path("../lib/metadata_ci.rb", __dir__)

class EntitiesTest < MiniTest::Test
  def test_good_files
    assert_empty(
      Check::Entities.batch(
        [File.expand_path("fixtures/csv/pamss045-invalid.csv", __dir__),
         File.expand_path("fixtures/csv/pamss045.csv", __dir__),
         File.expand_path("fixtures/mods/cusbmss228-p00001-invalid.xml",
                          __dir__),
         File.expand_path("fixtures/mods/cusbmss228-p00001.xml",
                          __dir__),]
      )
    )
  end

  def test_bad_csv
    refute_empty(
      Check::Entities.batch(
        [File.expand_path("fixtures/csv/html-entities.csv", __dir__)]
      )
    )
  end

  def test_bad_mods
    refute_empty(
      Check::Entities.batch(
        [File.expand_path("fixtures/mods/html-entities.xml", __dir__)]
      )
    )
  end
end
