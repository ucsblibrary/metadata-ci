# frozen_string_literal: true

require "minitest/autorun"
require File.expand_path("../../lib/check.rb", __FILE__)

class DateTemplateTest < MiniTest::Test
  def test_template_good
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
  end

  def test_template_bad
    assert_raises InvalidDate do
      Check::Date.template("194-02-28")
    end

    assert_raises InvalidDate do
      Check::Date.template("194")
    end

    assert_raises InvalidDate do
      Check::Date.template("1940-2")
    end

    assert_raises InvalidDate do
      Check::Date.template("1940-2-28")
    end

    assert_raises InvalidDate do
      Check::Date.template("1940-02-2")
    end

    assert_raises InvalidDate do
      Check::Date.template("1940-2-2")
    end

    assert_raises InvalidDate do
      Check::Date.template("2/28/1940")
    end

    assert_raises InvalidDate do
      Check::Date.template("28/2/1940")
    end

    assert_raises InvalidDate do
      Check::Date.template("2-28-1940")
    end

    assert_raises InvalidDate do
      Check::Date.template("28-2-1940")
    end

    assert_raises InvalidDate do
      Check::Date.template("2-2-1940")
    end

    assert_raises InvalidDate do
      Check::Date.template("February 28, 1940")
    end

    assert_raises InvalidDate do
      Check::Date.template("Feb 28, 1940")
    end

    assert_raises InvalidDate do
      Check::Date.template("28 February 1940")
    end

    assert_raises InvalidDate do
      Check::Date.template("28 Feb 1940")
    end

    assert_raises InvalidDate do
      Check::Date.template("Feb. 28, 1940")
    end

    assert_raises InvalidDate do
      Check::Date.template("28 Feb. 1940")
    end

    assert_raises InvalidDate do
      Check::Date.template("February 1940")
    end

    assert_raises InvalidDate do
      Check::Date.template("Feb. 1940")
    end

    assert_raises InvalidDate do
      Check::Date.template("1940 February")
    end

    assert_raises InvalidDate do
      Check::Date.template("1940 Feb.")
    end
  end

  def test_strptime
    assert_raises ArgumentError do
      DateTime.strptime("1940-02-30", Check::Date.template("1940-02-30"))
    end

    assert_raises ArgumentError do
      DateTime.strptime("02/28/1940", Check::Date.template("02/28/1940"))
    end

    assert_raises ArgumentError do
      DateTime.strptime("28/02/1940", Check::Date.template("28/02/1940"))
    end

    assert_raises ArgumentError do
      DateTime.strptime("2/28/40", Check::Date.template("2/28/40"))
    end

    assert_raises ArgumentError do
      DateTime.strptime("28/2/40", Check::Date.template("28/2/40"))
    end

    assert_raises ArgumentError do
      DateTime.strptime("02-28-1940", Check::Date.template("02-28-1940"))
    end

    assert_raises ArgumentError do
      DateTime.strptime("28-02-1940", Check::Date.template("28-02-1940"))
    end

    assert_raises ArgumentError do
      DateTime.strptime("02-02-1940", Check::Date.template("02-02-1940"))
    end
  end
end
