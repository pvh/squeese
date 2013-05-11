require 'active_support' # workaround for bug with directly requiring aws
require 'aws'
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

	def work
		raise NoJobsDefined unless defined?(@@handlers)

		# this makes more sense when we get support for working a subset
		# of the available jobs.
		jobs = all_jobs

		jobs.each do |job|
			raise(NoSuchJob, job) unless @@handlers[job]
		end

		logger.info "Working #{jobs.size} jobs  :: [ #{jobs.join(' ')} ]"

		loop do
			work_one_job
		end
	end

	def work_one_job
		msg = queue.pop

		# don't be CPU greedy on a quiet queue
		unless msg
			sleep 2
			return
		end

		name, args = JSON.parse msg.body
		args = Hash.new {|h,k| h[k.to_s] if h.keys.include? k.to_s}.merge(args)
		logger.info({
			job: name,
			args: args
		})
		handler = @@handlers[name]
		raise(NoSuchJob, name) unless handler
		handler.call(args)
	rescue => e
		if msg
			logger.warning({
				exception: e,
				action: "drop",
				job: name,
				args: args
			})
		else
			logger.warning({
				exception: e,
				action: "retry"
			})
		end
	end

	def logger=(val)
		@@logger = val
	end

	def logger
		unless defined? @@logger
			@@logger ||= Logger.new(STDOUT)
			@@logger.formatter = proc { |severity, datetime, progname, message|
				JSON.dump({
					severity: severity,
					datetime: datetime,
					progname: progname || 'Squeese',
					message: message
				})
			}
		end
		@@logger
	end

	def sqs
		@sqs ||= Aws::Sqs.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'], :logger => logger)
	end

	def queue_name=(val)
		@@queue_name = val
	end

	def queue_name
		@@queue_name ||= (ENV['SQUEESE_QUEUE'] || "squeese")
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
