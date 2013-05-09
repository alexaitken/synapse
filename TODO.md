# TODO

+ Configuration DSL and dependency container
+ Simplified mixins for domain commands and events
  + For serialization, validation, building, etc.

== AxonFramework functionality

+ ~~Auditing component~~
+ Command bus
  + ~~DSL for defining and subscribing command handlers to command types~~
  + ~~Command validation (ActiveModel)~~
  + Asynchronous command bus
  + Command gateway
  + Abstraction of aggregate load/store
  + ~~Rollback policies~~
+ Event handling
  + Listener groups and group bus
  + Asynchronous event bus
  + Distributed event bus (AMQP)
  + ~~DSL for defining and mapping event handlers to event types~~
  + Metrics for event buses (Graphite, Ganglia, etc.)
  + Event replay framework
  + Event scheduling framework (Quartz-like)
+ Event sourcing
  + ~~Snapshot support~~
  + ~~Conflict resolution support~~
  + Caching repository
  + Hybrid ES repository
  + Hook into event handler wiring
+ Event store
  + ~~Mongo event store~~
  + Sequel event store
  + Management
+ Repository
  + Optimistic/pessimistic lock manager
  + Non-event sourced repository (MongoMapper and ActiveRecord?)
+ Process management
  + Core interfaces (50%)
  + Implementation
  + Wired processes
  + Asynchronous process management
  + Mongo process repository
+ Serialization
  + Clean serializer (to hash for Mongo, normal JSON for other; compare to Ox/Oj/Marshal)

== Lokad.CQRS functionality

+ ~~Message de-duplication~~
+ Engine processes
+ Message quarantine
+ Partitioning
  + Queue reader/writer abstraction
  + Queues for memory, Redis, AMQP, etc.
+ Projections
  + In-memory projections or serialized projections
+ Dashboard
  + Projection management and replay
  + Domain auditing
    + Command to produced event correlation
    + Command dispatch failures
+ DSL for defining event and command contracts
