require 'bundler/setup'

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start do

    add_filter '/spec/'

    add_filter do |source_file|
      source_file.lines.each do |line|
        if line.source =~ /raise NotImplementedError/
          line.skipped!
        end
      end

      false
    end

  end
end

require 'synapse-core'

require 'pp'
require 'rspec'
require 'rr'
require 'timecop'

Logging.logger.root.level = :error

RSpec.configure do |r|
  # Ox and Oj are not compatible with JRuby
  if defined? JRUBY_VERSION
    r.filter_run_excluding oj: true
    r.filter_run_excluding ox: true
  end
end
