# frozen_string_literal: true

# Utility methods
module Util
  # @param [String] str
  # @return [String]
  def self.bold(str)
    "\033[1;39m#{str}\033[0m"
  end
end
