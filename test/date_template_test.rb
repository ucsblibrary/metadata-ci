# frozen_string_literal: true

require "minitest/autorun"
require File.expand_path("../../lib/check.rb", __FILE__)

class DateTemplateTest < MiniTest::Test
  def test_template
    assert_equal "%Y", Check::Date.template("1997")
    assert_equal "%Y", Check::Date.template(1234)
    assert_equal "%Y", Check::Date.template(:bork)

    assert_equal "%Y-%m", Check::Date.template("1997-07")
    assert_equal "%Y-%m", Check::Date.template(1_234_567)
    assert_equal "%Y-%m", Check::Date.template(:bumbler)

    assert_equal "%F", Check::Date.template("1997-07-16")
    assert_equal "%F", Check::Date.template(1_123_456_789)
    assert_equal "%F", Check::Date.template(:hellokitty)

    assert_equal "%FT%R%:z", Check::Date.template("1997-07-16T19:20+01:00")
    assert_equal "%FT%R%:z", Check::Date.template(3_333_333_333_333_333_333_333)
    assert_equal "%FT%R%:z", Check::Date.template(:iamasymbolthatis22char)

    assert_equal "%FT%T%:z", Check::Date.template("1997-07-16T19:20:30+01:00")
    assert_equal "%FT%T%:z", Check::Date.template(3_333_333_333_333_333_333_333_333)
    assert_equal "%FT%T%:z", Check::Date.template(:iamasymbolthatis25charact)

    assert_equal "%FT%T.%L%:z", Check::Date.template("1997-07-16T19:20:30.45+01:00")
    assert_equal "%FT%T.%L%:z",
                 Check::Date.template(3_333_444_333_666_333_333_333_333_333)
    assert_equal "%FT%T.%L%:z", Check::Date.template(:iamasymbolthatis28characters)

    # Wrong lengths
    assert_raises InvalidDate do
      Check::Date.template("19970")
    end

    assert_raises InvalidDate do
      Check::Date.template(19_970)
    end

    assert_raises InvalidDate do
      Check::Date.template(:bumble)
    end

    assert_raises InvalidDate do
      Check::Date.template("1997-88-")
    end

    assert_raises InvalidDate do
      Check::Date.template(19_970_400)
    end

    assert_raises InvalidDate do
      Check::Date.template(:bumblers)
    end
  end
end
