require 'rake/testtask'
require 'yard'

require File.expand_path '../lib/synapse/version', __FILE__

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'lib' << 'test'
  t.test_files = FileList.new 'test/**/*test.rb'
end

task :build do
  Gem::Builder.new(eval(File.read('synapse-core.gemspec'))).build
end

YARD::Rake::YardocTask.new do |t|
  t.files << 'lib/**/*.rb'
  t.options += ['--title', "Synapse #{Synapse::VERSION} Documentation"]
end
