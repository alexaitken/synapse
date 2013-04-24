require 'rake/testtask'
require 'yard'

Rake::TestTask.new do |t|
  t.libs << 'lib' << 'test'
  t.test_files = FileList.glob 'test/**/*test.rb'
end

YARD::Rake::YardocTask.new do |t|
  t.files << 'lib/**/*.rb'
end
