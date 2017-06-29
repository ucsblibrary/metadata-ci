# frozen_string_literal: true

require "minitest/autorun"
require File.expand_path("../../lib/check.rb", __FILE__)

class EntitiesTest < MiniTest::Test
  def test_good_files
    assert_empty(
      Check::Entities.batch(
        [File.expand_path("../fixtures/csv/pamss045-invalid.csv", __FILE__),
         File.expand_path("../fixtures/csv/pamss045.csv", __FILE__),
         File.expand_path("../fixtures/mods/cusbmss228-p00001-invalid.xml",
                          __FILE__),
         File.expand_path("../fixtures/mods/cusbmss228-p00001.xml",
                          __FILE__),]
      )
    )
  end

  def test_bad_csv
    refute_empty(
      Check::Entities.batch(
        [File.expand_path("../fixtures/csv/html-entities.csv", __FILE__)]
      )
    )
  end

  def test_bad_mods
    refute_empty(
      Check::Entities.batch(
        [File.expand_path("../fixtures/mods/html-entities.xml", __FILE__)]
      )
    )
  end
end
