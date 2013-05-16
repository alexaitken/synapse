require 'rake/testtask'
require 'yard'

task :default => :test

Rake::TestTask.new do |t|
  test_files = FileList.new 'test/**/*test.rb'
  test_files.exclude 'test/functional/**/*'

  t.libs << 'lib' << 'test'
  t.test_files = test_files
end

Rake::TestTask.new do |t|
  test_files = FileList.new 'test/functional/**/*test.rb'

  t.libs << 'lib' << 'test'
  t.name = :test_functional
  t.test_files = test_files
end

YARD::Rake::YardocTask.new do |t|
  t.files << 'lib/**/*.rb'
end
