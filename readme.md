# Synapse

Synapse is a CQRS and event sourcing framework for Ruby 1.9.3 and later.

[![Code Climate](https://codeclimate.com/github/ianunruh/synapse.png)](https://codeclimate.com/github/ianunruh/synapse)
[![Coverage Status](https://coveralls.io/repos/ianunruh/synapse/badge.png?branch=master)](https://coveralls.io/r/ianunruh/synapse)
[![Build Status](https://travis-ci.org/ianunruh/synapse.png?branch=master)](https://travis-ci.org/ianunruh/synapse)
[![Gem Version](https://badge.fury.io/rb/synapse-core.png)](http://badge.fury.io/rb/synapse-core)

Synapse is partially an idiomatic port of [AxonFramework](http://axonframework.com) and [Lokad.CQRS](http://lokad.github.io/lokad-cqrs)

## Getting Started

Define your commands and events using plain old Ruby objects, or POROs

    class CreateAccount
      attr_accessor :account_id, :name

      def initialize(account_id, name)
        # ...
      end
    end

    class AccountCreated
      attr_accessor :account_id, :name

      # ...
    end

Define the aggregate

    class Account
      include Synapse::Domain::AggregateRoot
      include ActiveRecord::Base

      def initialize(id, name)
        self.id = id
        self.name = name

        publish_event AccountCreated.new id, name
      end
    end

Define the command handler

    class AccountCommandHandler
      include Synapse::Command::WiringCommandHandler
      include Synapse::Configuration::Dependent

      depends_on :account_repository

      wire CreateAccount do |command|
        account = Account.new command.id, command.name
        @account_repository.add account
      end
    end

Setup the necessary services

    Synapse.build do
      converter_factory

      serializer do
        use_ox
      end

      unit_factory

      simple_command_bus
      simple_event_bus

      gateway

      simple_repository :account_repository do
        use_aggregate_type Account
      end

      # Register your command handler so it can be subscribed to the command bus
      factory :account_command_handler, :tag => :command_handler do
        AccountCommandHandler.new
      end
    end

aaaaaand you're done!

    command = CreateAccount.new 123, 'Checking'

    gateway = Synapse.container[:gateway]
    gateway.send command

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
