require 'test_helper'

class IntegrationTest < IchniteTest
  def setup
    @original_logger = Ichnite.default_logger
    Ichnite.default_logger = nil
    super
  end

  def teardown
    Ichnite.default_logger = @original_logger
    super
  end

  def test_default_logger_is_to_stdout
    output = StringIO.new
    begin
      $stdout = output
      Ichnite.log(:request_served)
    ensure
      $stdout = STDOUT
    end
    assert_equal "event=request_served\n", output.string
  end
end
