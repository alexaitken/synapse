# Synapse

Synapse is a CQRS and event sourcing framework for Ruby 1.9.3 and later.

[![Code Climate](https://codeclimate.com/github/iunruh/synapse.png)](https://codeclimate.com/github/iunruh/synapse)
[![Coverage Status](https://coveralls.io/repos/iunruh/synapse/badge.png?branch=master)](https://coveralls.io/r/iunruh/synapse)
[![Build Status](https://travis-ci.org/iunruh/synapse.png?branch=master)](https://travis-ci.org/iunruh/synapse)
[![Dependency Status](https://gemnasium.com/iunruh/synapse.png)](https://gemnasium.com/iunruh/synapse)

Synapse is partially an idiomatic port of [AxonFramework](http://axonframework.com)

## Features

- Mixins for aggregate members (root and member entities)
- Separation of events and commands
- Event store (backed by MongoDB)
- Snapshot support
- Conflict detection support
- Event upcasting
- Command validation (using ActiveModel)
- Simple object serialization

## Coming soon
- Process manager framework (also known as Saga management, in CQRS terms)
- DSL for easy wiring of event and command handlers
- Repository for non-event sourced aggregates (MongoMapper and ActiveRecord)
- Event store using Sequel
- Distributed command and event buses (using AMQP)
- Event replay and projection framework
- Event scheduling
