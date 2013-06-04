# Synapse

Synapse is a CQRS and event sourcing framework for Ruby 1.9.3 and later.

[![Code Climate](https://codeclimate.com/github/ianunruh/synapse.png)](https://codeclimate.com/github/ianunruh/synapse)
[![Coverage Status](https://coveralls.io/repos/ianunruh/synapse/badge.png?branch=master)](https://coveralls.io/r/ianunruh/synapse)
[![Build Status](https://travis-ci.org/ianunruh/synapse.png?branch=master)](https://travis-ci.org/ianunruh/synapse)
[![Gem Version](https://badge.fury.io/rb/synapse-core.png)](http://badge.fury.io/rb/synapse-core)

Synapse is partially an idiomatic port of [AxonFramework](http://axonframework.com) and [Lokad.CQRS](http://lokad.github.io/lokad-cqrs)

**Warning:** Synapse is still under heavy development; public API can change at any time.

## Getting Started

You know the drill, add it to your `Gemfile`:

```ruby
gem 'synapse-core'
gem 'synapse-mongo'

# Or if you're feeling edgy
gem 'synapse-core', :git => 'git://github.com/ianunruh/synapse.git', :branch => :master
gem 'synapse-mongo', :git => 'git://github.com/ianunruh/synapse-mongo.git', :branch => :master
```

You can define your commands and events using plain old Ruby objects.

```ruby
class CreateAccount
  attr_reader :id, :name
  def initialize(id, name)
    @id = id
    @name = name
  end
end

class AccountCreated
  # ...
end
```

Define the aggregate -- In this case, an event-sourced aggregate.

```ruby
class Account
  include Synapse::EventSourcing::AggregateRoot

  def initialize(id, name)
    apply AccountCreated.new id, name
  end

  map_event AccountCreated do |event|
    @id = event.id
    @name = event.name
  end
end
```

Define the command handler

```ruby
class AccountCommandHandler
  include Synapse::Command::MappingCommandHandler
  include Synapse::Configuration::Dependent

  depends_on :account_repository

  map_command CreateAccount do |command|
    account = Account.new command.id, command.name
    @account_repository.add account
  end
end
```

Setup the necessary services

```ruby
Synapse.build do
  simple_event_bus

  unit_factory
  simple_command_bus
  gateway

  converter_factory
  serializer

  mongo_event_store do
    use_client Mongo::MongoClient.new
  end

  # The repository gets cool things injected, like locking, an event bus and event store
  es_repository :account_repository do
    use_aggregate_type Account
  end

  # Register your command handler so it can be subscribed to the command bus and get its own
  # dependencies injected upon creation
  factory :account_command_handler, :tag => :command_handler do
    inject_into AccountCommandHandler.new
  end
end
```

aaaaaand you're done!

```ruby
command = CreateAccount.new 123, 'Checking'

# This could be done in a Rails controller or Sinatra
gateway = Synapse.container[:gateway]
gateway.send command
```

## Features

- Mixins for aggregate members (root and member entities)
- Separation of events and commands
- Event store (backed by MongoDB)
- Snapshot support
- Conflict detection support
- Event upcasting
- Command validation (using ActiveModel)
- Simple object serialization
- DSL for easy mapping of event and command handlers
- Process manager framework (also known as Saga management)
- Repository for non-event sourced aggregates (MongoMapper and ActiveRecord)

## Compatibility

Synapse is tested and developed on several different runtimes, including:

- MRI 1.9.3
- MRI 2.0.0
- JRuby 1.7.3
- Rubinius 2.0.0-rc1 (rbx-head)

## Coming soon
- Event store using Sequel
- Distributed command and event buses (engine partitioning)
- Event replay and projection framework
- Event scheduling
