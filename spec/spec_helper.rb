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
