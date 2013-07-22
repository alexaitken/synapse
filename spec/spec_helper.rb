require 'bundler/setup'

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'synapse-core'

require 'pp'
require 'rspec'
require 'rr'
require 'timecop'

require 'wait_helper'

RSpec.configure do |r|
  # Ox and Oj are not compatible with JRuby
  if defined? JRUBY_VERSION
    r.filter_run_excluding ox: true
    r.filter_run_excluding oj: true
  end
end
