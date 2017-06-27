# frozen_string_literal: true

# Used by {CheckDate} to determine if metadata date-strings are
# W3C-valid (https://www.w3.org/TR/1998/NOTE-datetime-19980827)
class InvalidDate < StandardError; end
