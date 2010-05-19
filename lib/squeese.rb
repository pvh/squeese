require 'right_aws'
require 'json'
require 'uri'

module Squeese
	extend self

	def purge
		queue.delete
	end

	def enqueue(job, args={})
		queue.send_message [ job, args ].to_json
	end

	def job(j, &block)
		@@handlers ||= {}
		@@handlers[j] = block
	end

	class NoJobsDefined < RuntimeError; end
	class NoSuchJob < RuntimeError; end

	def work(jobs=nil)
		raise NoJobsDefined unless defined?(@@handlers)

		jobs ||= all_jobs

		jobs.each do |job|
			raise(NoSuchJob, job) unless @@handlers[job]
		end

		log "Working #{jobs.size} jobs  :: [ #{jobs.join(' ')} ]"

		loop do
			work_one_job
		end
	end

	def work_one_job
		msg = queue.receive

		# don't be CPU greedy on a quiet queue
		unless msg
			sleep 2
			return
		end

		name, args = JSON.parse msg.body
		log_job(name, args)
		handler = @@handlers[name]
		raise(NoSuchJob, name) unless handler
		handler.call(args)
		msg.delete
	rescue => e
		log exception_message(e)
	end

	def log_job(name, args)
		args_flat = args.inject("") do |accum, (key,value)|
			accum += "#{key}=#{value} "
		end

		log sprintf("%-15s :: #{args_flat}", name)
	end

	def log(msg)
		puts "[#{Time.now}] #{msg}"
	end

	def sqs
		@sqs ||= RightAws::SqsGen2.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'], :logger => Logger.new(nil))
	end

	def queue_name
		ENV["SQS_QUEUE"] || "squeese"
	end

	def queue
		sqs.queue(queue_name, true)
	end

	def exception_message(e)
		msg = [ "Exception #{e.class} -> #{e.message}" ]

		base = File.expand_path(Dir.pwd) + '/'
		e.backtrace.each do |t|
			msg << "   #{File.expand_path(t).gsub(/#{base}/, '')}"
		end

		msg.join("\n")
	end

	def all_jobs
		@@handlers.keys
	end
end
