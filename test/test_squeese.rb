require 'test/unit'
require 'stubs'

require 'squeese'

module Squeese
  def queue
    MockSQSQueue.new
  end
end

class SqueeseTest < Test::Unit::TestCase

  def test_queue_name
    ENV['SQUEESE_QUEUE'] = 'test_queue_name'
    assert_equal 'test_queue_name', Squeese.queue_name

    Squeese.queue_name = 'override'
    assert_equal 'override', Squeese.queue_name
  end

  def test_push_pop
    Squeese.job("test") {|item| assert_equal 1, item}

    assert Squeese.enqueue("test", 1), "Could not enqueue"
    Squeese.work_one_job
  end
end
