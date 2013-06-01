# Synapse

Synapse is a CQRS and event sourcing framework for Ruby 1.9.3 and later.

[![Code Climate](https://codeclimate.com/github/ianunruh/synapse.png)](https://codeclimate.com/github/ianunruh/synapse)
[![Coverage Status](https://coveralls.io/repos/ianunruh/synapse/badge.png?branch=master)](https://coveralls.io/r/ianunruh/synapse)
[![Build Status](https://travis-ci.org/ianunruh/synapse.png?branch=master)](https://travis-ci.org/ianunruh/synapse)
[![Gem Version](https://badge.fury.io/rb/synapse-core.png)](http://badge.fury.io/rb/synapse-core)

Synapse is partially an idiomatic port of [AxonFramework](http://axonframework.com) and [Lokad.CQRS](http://lokad.github.io/lokad-cqrs)

**Warning:** Synapse is still under heavy development; public API is likely to break before a stable release is announced.

## Getting Started

You know the drill, add it to your `Gemfile`:

```ruby
gem 'synapse-core'
```

You can define your commands and events using plain old Ruby objects. To make serialization and validation
easier, however, you should use some sort of model mixin, like:

- [ActiveAttr](https://github.com/cgriego/active_attr)
- [ActiveModel](https://github.com/rails/rails/tree/master/activemodel)
- [Virtus](https://github.com/solnic/virtus)

```ruby
class CreateAccount
  include Virtus

  attribute :account_id, String
  attribute :name, String
end

class AccountCreated
  include Virtus

  # ...
end
```

Define the aggregate -- In this case, a non-event sourced aggregate, stored with ActiveRecord.

You can use any ORM to define non-ES aggregates, including MongoMapper, Mongoid and DataMapper.
To use event sourcing, you have to configure an event store, like the one in [synapse-mongo](https://github.com/ianunruh/synapse-mongo)

```ruby
class Account
  include ActiveRecord::Base
  include Synapse::Domain::AggregateRoot

  def initialize(id, name)
    self.id = id
    self.name = name

    publish_event AccountCreated.new id, name
  end
end
```

Define the command handler

```ruby
class AccountCommandHandler
  include Synapse::Command::WiringCommandHandler
  include Synapse::Configuration::Dependent

  depends_on :account_repository

  wire CreateAccount do |command|
    account = Account.new command.id, command.name
    @account_repository.add account
  end
end
```

Setup the necessary services

```ruby
Synapse.build do
  converter_factory
  serializer
  unit_factory

  simple_command_bus
  simple_event_bus

  gateway

  # The repository gets cool things injected, like locking and an event bus
  simple_repository :account_repository do
    use_aggregate_type Account
  end

  # Register your command handler so it can be subscribed to the command bus and get its own
  # dependencies injected upon creation
  factory :account_command_handler, :tag => :command_handler do
    AccountCommandHandler.new
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
- DSL for easy wiring of event and command handlers
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
