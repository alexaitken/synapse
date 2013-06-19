![Synapse logo](http://i.imgur.com/BIwv418.png)

Synapse is a CQRS and event sourcing framework for Ruby 1.9.3 and later.

[![Code Climate](https://codeclimate.com/github/ianunruh/synapse.png)](https://codeclimate.com/github/ianunruh/synapse)
[![Coverage Status](https://coveralls.io/repos/ianunruh/synapse/badge.png?branch=master)](https://coveralls.io/r/ianunruh/synapse)
[![Build Status](https://travis-ci.org/ianunruh/synapse.png?branch=master)](https://travis-ci.org/ianunruh/synapse)
[![Gem Version](https://badge.fury.io/rb/synapse-core.png)](http://badge.fury.io/rb/synapse-core)

Synapse is partially an idiomatic port of [AxonFramework](http://axonframework.com) and [Lokad.CQRS](http://lokad.github.io/lokad-cqrs)

**Warning:** Synapse is still under development; public API can change at any time.

## Quickstart

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
class CreateInventoryItem
  attr_reader :id, :description

  def initialize(id, description)
    @id = id
    @description = description
  end
end
```

Define the aggregate -- In this case, an event-sourced aggregate.

```ruby
class InventoryItem
  include Synapse::EventSourcing::AggregateRoot

  def initialize(id, description)
    apply InventoryItemCreated.new id, description
  end

  def check_in(quantity)
    apply StockCheckedIn.new id, quantity
  end

  map_event InventoryItemCreated do |event|
    @id = event.id
  end

  map_event StockCheckedIn do |event|
    @stock = @stock + event.quantity
  end
end
```

Define the command handler

```ruby
class InventoryItemCommandHandler
  include Synapse::Command::MappingCommandHandler

  attr_accessor :repository

  map_command CreateInventoryItem do |command|
    item = InventoryItem.new command.id, command.description
    @repository.add item
  end

  map_command CheckInStock do |command|
    item = @repository.load command.id
    item.check_in command.quantity
  end
end
```

Wire everything up

```ruby
Synapse.build_with_defaults do
  mongo_event_store do
    use_client Mongo::MongoClient.new
  end

  es_repository :item_repository do
    use_aggregate_type InventoryItem
  end

  # Register your command handler so it can be subscribed to the command bus and get its own
  # dependencies injected upon creation
  factory :item_command_handler, :tag => :command_handler do
    handler = InventoryItemCommandHandler.new
    handler.repository = resolve :item_repository

    handler
  end
end
```

aaaaaand you're done!

```ruby
class InventoryItemController < ApplicationController
  def create
    # ...

    command = CreateInventoryItem.new sku, description

    gateway = Synapse.container.resolve :gateway
    gateway.send command
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
- Aggregates as command handlers
- Event replay and projection framework
- Event scheduling
