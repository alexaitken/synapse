require 'rspec/core/rake_task'
require 'yard'

require File.expand_path '../lib/synapse/version', __FILE__

task :default => :spec

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = '--format d'
end

task :build do
  Gem::Builder.new(eval(File.read('synapse-core.gemspec'))).build
end

YARD::Rake::YardocTask.new do |t|
  t.files << 'lib/**/*.rb'
  t.options += ['--title', "Synapse #{Synapse::VERSION} Documentation"]
end
