require 'aws'

class MockSQSQueue

  def delete
    true
  end

  def send_message(body)
    @q ||= []
    @q.push(Aws::Sqs::Message.new(self, "MockMessageId=", nil, body))
    {MessageId: "MockMessageId=",
     MD5OfMessageBody: "deadbeef"}
  end

  def pop
    @q ||= []
    @q.pop
  end

end
