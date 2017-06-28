# frozen_string_literal: true

require "minitest/autorun"
require File.expand_path("../../lib/check.rb", __FILE__)

class EncodingTest < MiniTest::Test
  def test_good_encodings
    assert_empty Check::Encoding.batch(Dir.glob("../fixtures/csv/*.csv"))
    assert_empty Check::Encoding.batch(Dir.glob("../fixtures/mods/*.xml"))
  end

  def test_bad_encoding
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
