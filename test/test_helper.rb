$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ichnite'
require 'ichnite/testing'

require 'minitest/autorun'

class IchniteTest < Minitest::Test
  include Ichnite::TestHelper

  def teardown
    super
    # Hack as this wont be possible through the API
    Ichnite.instance_variable_set("@augments", [])
    Ichnite.leave
  end
end
