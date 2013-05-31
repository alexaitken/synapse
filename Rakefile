require 'rake/testtask'
require 'yard'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'lib' << 'test'
  t.test_files = FileList.new 'test/**/*test.rb'
end

YARD::Rake::YardocTask.new do |t|
  t.files << 'lib/**/*.rb'
end
