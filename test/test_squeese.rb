require 'test/unit'

require 'squeese'


class SqueeseTest < Test::Unit::TestCase

  def test_queue_name
    ENV['SQUEESE_QUEUE'] = 'test_queue_name'
    assert_equal 'test_queue_name', Squeese.queue_name

    Squeese.queue_name = 'override'
    assert_equal 'override', Squeese.queue_name
  end
end
