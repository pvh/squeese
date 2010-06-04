$LOAD_PATH.unshift '../lib'
require 'squeese'

Squeese.queue_name = "example"
Squeese.enqueue('send.email', :email => 'hello@example.com')
Squeese.enqueue('cleanup.strays')
