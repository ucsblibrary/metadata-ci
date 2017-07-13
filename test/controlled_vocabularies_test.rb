# frozen_string_literal: true

require "minitest/autorun"
require File.expand_path("../../lib/check.rb", __FILE__)

class ControlledVocabulariesTest < MiniTest::Test
  def test_good_files
    errors = Check::ControlledVocabularies.batch(
      [File.expand_path("../fixtures/csv/pamss045-invalid.csv", __FILE__),
       File.expand_path("../fixtures/csv/pamss045.csv", __FILE__),
       File.expand_path("../fixtures/mods/cusbmss228-p00001-invalid.xml",
                        __FILE__),
       File.expand_path("../fixtures/mods/cusbmss228-p00001.xml",
                        __FILE__),]
    )

    assert_empty errors
  end

  def test_bad_csv
    errors = Check::ControlledVocabularies.batch(
      [File.expand_path("../fixtures/csv/pamss045-uncontrolled.csv", __FILE__)]
    )

    assert_equal 2, errors.count
    assert_includes errors.map(&:problem),
                    "'Bundle' is not an allowed object type."

    assert_includes errors.map(&:problem),
                    "'Department of Mysteries' is not an allowed location."
  end

  def test_bad_mods
    errors = Check::ControlledVocabularies.batch(
      [File.expand_path("../fixtures/mods/cusbmss228-p00001-uncontrolled.xml",
                        __FILE__),]
    )

    assert_equal 2, errors.count
    assert_includes errors.map(&:problem),
                    "'wiggly image' is not an allowed object type."

    assert_includes errors.map(&:problem),
                    "'Somewhere outside Memphis' is not an allowed location."
  end
end
