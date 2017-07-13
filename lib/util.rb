# frozen_string_literal: true

# Utility methods
module Util
  # For each element, if it's a file, add it to the array, otherwise
  # drill down and add each file within to the array
  #
  # @param [Array<String>] params Usually ARGV
  # @return [Array<String>
  def self.find_paths(params)
    params.map do |arg|
      next arg if File.file?(arg)

      next unless Dir.exist?(arg)

      Find.find(arg).map do |path|
        next if File.directory?(path)
        path
      end
    end.flatten.compact
  end

  # @param [String] str
  # @return [String]
  def self.bold(str)
    return str unless $stdout.tty?

    "\033[1;39m#{str}\033[0m"
  end

  # @param [String] str
  # @return [String]
  def self.warn(str)
    return str unless $stdout.tty?

    "\033[4;33m#{str}\033[0m"
  end
end
