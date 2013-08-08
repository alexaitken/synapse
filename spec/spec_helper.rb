require 'bundler/setup'
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

require 'synapse-core'

require 'logger'
require 'pp'
require 'rspec'
require 'rr'

Synapse.configure
