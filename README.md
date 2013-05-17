# Synapse

Synapse is a CQRS and event sourcing framework for Ruby 1.9.3 and later.

[![Code Climate](https://codeclimate.com/github/ianunruh/synapse.png)](https://codeclimate.com/github/ianunruh/synapse)
[![Coverage Status](https://coveralls.io/repos/ianunruh/synapse/badge.png?branch=master)](https://coveralls.io/r/ianunruh/synapse)
[![Build Status](https://travis-ci.org/ianunruh/synapse.png?branch=master)](https://travis-ci.org/ianunruh/synapse)
[![Gem Version](https://badge.fury.io/rb/synapse-core.png)](http://badge.fury.io/rb/synapse-core)

Synapse is partially an idiomatic port of [AxonFramework](http://axonframework.com) and [Lokad.CQRS](http://lokad.github.io/lokad-cqrs)

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

## Coming soon
- Repository for non-event sourced aggregates (MongoMapper and ActiveRecord)
- Event store using Sequel
- Distributed command and event buses (engine partitioning)
- Event replay and projection framework
- Event scheduling
