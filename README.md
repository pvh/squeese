SQueeSe - a job queueing DSL for SQS
==========================================

SQS is a queueing system from Amazon. SQueeSe is a friendly wrapper around it in the style of Stalker or Minion.

Queueing jobs
-------------

From anywhere in your app:

    require 'squeese'

    Squeese.enqueue('email.send', :to => 'joe@example.com')
    Squeese.enqueue('post.cleanup.all')
    Squeese.enqueue('post.cleanup', :id => post.id)

Working jobs
------------

In a standalone file, typically jobs.rb or worker.rb:

    require 'squeese'
    include Squeese

    job 'email.send' do |args|
      Pony.send(:to => args['to'], :subject => "Hello there")
    end

    job 'post.cleanup.all' do |args|
      Post.all.each do |post|
        enqueue('post.cleanup', :id => post.all)
      end
    end

    job 'post.cleanup' do |args|
      Post.find(args['id']).cleanup
    end

Running
-------

First, make sure you have your AWS secret keys configured.

    $ export AWS_SECRET_ACCESS_KEY=[...]
    $ export AWS_ACCESS_KEY_ID=[...]

Now get your squeese on:

    $ sudo gem install squeese

Now squeese tight with a worker:

    $ squeese jobs.rb
    [Sat Apr 17 14:13:40 -0700 2010] Working 3 jobs  :: [ email.send post.cleanup.all post.cleanup ]

Squeese will log to stdout as it starts working each job.

Filter to a list of jobs you wish to run with an argument:

    $ squeese jobs.rb post.cleanup.all,post.cleanup
    [Sat Apr 17 14:13:40 -0700 2010] Working 2 jobs  :: [ post.cleanup.all post.cleanup ]

In a production environment you may run one or more high-priority workers (limited to short/urgent jobs) and any number of regular workers (working all jobs).  For example, two workers working just the email.send job, and four running all jobs:

    $ for i in 1 2; do squeese jobs.rb email.send > log/urgent-worker.log 2>&1; end
    $ for i in 1 2 3 4; do squeese jobs.rb > log/worker.log 2>&1; end

NOTE:
Filtering squeese jobs by worker is not yet supported!

Tidbits
-------

* Jobs are serialized as JSON, so you should stick to strings, integers, arrays, and hashes as arguments to jobs.  e.g. don't pass full Ruby objects - use something like an ActiveRecord/MongoMapper/CouchRest id instead.
* Because there are no class definitions associated with jobs, you can queue jobs from anywhere without needing to include your full app's environment.
* The default queue name used by squeese is "squeese", but you can select a different queue with ENV['SQUEESE_QUEUE'].
* The squeese binary is just for convenience, you can also run a worker with a straight Ruby command:
    $ ruby -r jobs -e Squeese.work

Meta
----

Created by Peter van Hardenberg (sort of)

Heavily inspired by^W^Wderived from [Minion](http://github.com/orionz/minion) and [Stalker](http://github.com/adamwiggins/stalker) by Orion Henry and Adam Wiggins, respectively.

Released under the MIT License: http://www.opensource.org/licenses/mit-license.php

http://github.com/pvh/squeese

