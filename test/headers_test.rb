# frozen_string_literal: true

require "minitest/autorun"
require File.expand_path("../../lib/metadata_ci.rb", __FILE__)

class HeadersTest < MiniTest::Test
  def test_good_files
    assert_empty(
      Check::Headers.batch(
        [File.expand_path("../fixtures/csv/pamss045-invalid.csv", __FILE__),
         File.expand_path("../fixtures/csv/pamss045.csv", __FILE__),
         File.expand_path("../fixtures/mods/cusbmss228-p00001-invalid.xml",
                          __FILE__),
         File.expand_path("../fixtures/mods/cusbmss228-p00001.xml",
                          __FILE__),]
      )
    )
  end

  def test_required
    errors = Check::Headers.batch(
      [File.expand_path("../fixtures/csv/pamss045-missing-required.csv",
                        __FILE__),]
    )
    assert_equal 2, errors.length

    assert_includes errors.map(&:problem),
                    "Missing required 'access_policy' header."
    assert_includes errors.map(&:problem),
                    "All required 'created' headers "\
                    "must be used (missing 'created_start')."
  end

  def test_undefined
    errors = Check::Headers.batch(
      [File.expand_path("../fixtures/csv/pamss045-undefined.csv",
                        __FILE__),]
    )
    assert_equal 1, errors.length
    assert_equal errors.first.problem, "'animal' is not an allowed header."
  end

  def test_order
    errors = Check::Headers.batch(
      [File.expand_path("../fixtures/csv/pamss045-unordered.csv",
                        __FILE__),]
    )
    problems = errors.map(&:problem)

    assert_equal 3, errors.length
    assert_includes problems,
                    "'created_start' should be followed by 'created_finish'."
    assert_includes problems,
                    "'created_finish' should be followed by 'created_label'."
    assert_includes problems,
                    "'created_start_qualifier' should be "\
                    "followed by 'created_finish_qualifier'."
  end
end
