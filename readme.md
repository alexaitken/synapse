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
gem 'synapse-core', :github => 'ianunruh/synapse', :branch => :master
gem 'synapse-mongo', :github => 'ianunruh/synapse-mongo', :branch => :master
```

You can define your commands and events using plain old Ruby objects.

```ruby
class CreateAccount
  attr_reader :account_id, :name
  def initialize(id, name)
    @account_id = id
    @name = name
  end
end

class RenameAccount
  # ...
end

class AccountCreated
  # ...
end

class AccountRenamed
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

  def rename(name)
    apply AccountRenamed.new id, name
  end

  map_event AccountCreated do |event|
    @id = event.id
    @name = event.name
  end

  map_event AccountRenamed do |event|
    @name = event.new_name
  end
end
```

Define the command handler

```ruby
class AccountCommandHandler
  include Synapse::Command::MappingCommandHandler
  include Synapse::Configuration::Dependent

  depends_on :account_repository, :as => :repository

  map_command CreateAccount do |command|
    account = Account.new command.id, command.name
    @repository.add account
  end

  map_command RenameAccount do |command|
    account = @repository.load command.account_id
    account.rename command.new_name
  end
end
```

Setup the necessary services

```ruby
Synapse.build_with_defaults do
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
class AccountController < ApplicationController
  # oooo shiny
  depends_on :gateway

  def create
    command = CreateAccount.new 123, 'Checking'
    @gateway.send command
  end
end
```

## Features

- Event sourced aggregates
  - DSL for specifying event handlers and aggregate members
  - Event store backed by MongoDB
  - Aggregate snapshot support
  - Conflict resolution with optimistic locking
- Non-event sourced aggregates
  - Supports persistence using ActiveRecord, MongoMapper, DataMapper, Mongoid, etc.
- DSL for easy mapping of event and command handlers
- Command validation (using ActiveModel)
- Simple object serialization
  - Ox, Oj and Marshal
  - Attribute-based serialization to JSON/XML
  - Deprecated events can be loaded and upcast into new formats
- Process manager framework (also known as Saga management)

## Compatibility

Synapse is tested and developed on several different runtimes, including:

- MRI 1.9.3
- MRI 2.0.0
- JRuby 1.7.3
- Rubinius 2.0.0-rc1 (rbx-head)

## Coming soon
- Event store using Sequel
- Distributed command and event buses (partitioning)
- Aggregate command handlers
- Event replay and projection framework
- Event scheduling
