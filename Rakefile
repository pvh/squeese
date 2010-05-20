require 'jeweler'

Jeweler::Tasks.new do |s|
	s.name = "squeese"
	s.summary = "A job queueing and background workers system using SQS."
	s.description = "A job queueing and background workers system using SQS.  Inspired by the Stalker gem."
	s.author = "Peter van Hardenberg"
	s.email = "pvh@heroku.com"
	s.homepage = "http://github.com/pvh/squeese"
	s.executables = [ "squeese" ]
	s.rubyforge_project = "squeese"

	s.add_dependency 'aws'
	s.add_dependency 'json_pure'

	s.files = FileList["[A-Z]*", "{bin,lib}/**/*"]
end

Jeweler::GemcutterTasks.new
