# frozen_string_literal: true

require "minitest/autorun"
require File.expand_path("../../lib/date_checker.rb", __FILE__)

class ModsTest < MiniTest::Test
  def test_mods_fields
    refute_empty DateChecker.mods_fields
    assert(DateChecker.mods_fields.all? { |c| c.is_a? String })
  end

  def test_mods_checking
    assert_empty(
      DateChecker.mods(
        File.expand_path("../fixtures/mods/cusbmss228-p00001.xml", __FILE__)
      )
    )

    errors = DateChecker.mods(
      File.expand_path("../fixtures/mods/cusbmss228-p00001-invalid.xml",
                       __FILE__)
    )
    refute_empty errors
    assert_equal 1, errors.count
    assert(errors.all? { |e| e.is_a? InvalidDate })
  end
end
