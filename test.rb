require 'bundler/setup'
require 'synapse'
require 'pp'

message = Synapse::Domain::DomainEventMessage.build do |b|
  b.payload = 'derp'
end

pp message.with_metadata Hash.new

