require 'minitest/autorun'
require 'active_support'
require 'active_support/testing/time_helpers'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/date/calculations'

class Minitest::Test
  include ActiveSupport::Testing::TimeHelpers
end
