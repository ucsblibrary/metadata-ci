# frozen_string_literal: true

Dir.glob(File.expand_path("check/*.rb", __dir__)).each do |f|
  require f
end

# Parent module for all checks
module Check; end
