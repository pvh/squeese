# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'

Jeweler::Tasks.new do |gem|
	gem.name = "squeese"
	gem.summary = "A job queueing and background workers system using SQS."
	gem.description = "A job queueing and background workers system using SQS.  Inspired by the Stalker gem."
	gem.author = "Peter van Hardenberg"
	gem.email = "pvh@heroku.com"
	gem.homepage = "http://github.com/pvh/squeese"
	gem.executables = [ "squeese" ]
	gem.rubyforge_project = "squeese"

	gem.add_dependency 'aws'
	gem.add_dependency 'json_pure'

	gem.files = FileList["[A-Z]*", "{bin,lib}/**/*"]
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

Jeweler::GemcutterTasks.new
