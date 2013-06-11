# TODO

## Immediate

+ Issues on GitHub

## AxonFramework functionality

+ Command bus
  + Instrumentation for command buses (Graphite, Ganglia, etc.)
  + Abstraction of aggregate load/store (plus aggregate target DSL)
+ Event handling
  + Listener groups and group bus
  + Asynchronous event bus
  + Distributed event bus (AMQP)
  + Instrumentation for event buses (Graphite, Ganglia, etc.)
  + Event replay framework
  + Event scheduling framework (Quartz-like)
+ Event sourcing
  + Hybrid ES repository
+ Event store
  + Management
+ Process management
  + Asynchronous process management
+ Serialization
  + Nokogiri serializer

## Integration

+ Sequel
  + Event store
  + Process repository

## Lokad.CQRS functionality

+ Engine processes
+ Message quarantine
+ Partitioning
  + Queue reader/writer abstraction
  + JSON, BSON, MsgPack message packing
  + In-memory queue
  + AMQP queue
  + Redis queue
+ Projections
  + In-memory projections or serialized projections
+ Dashboard
  + Projection management and replay
  + Domain auditing
    + Command -> events correlation
    + Command dispatch failures
+ DSL for defining event and command contracts

## Odds and ends

+ Simplified mixins for domain commands and events
  + For serialization, validation, building, etc.
+ Disruptor for command bus (??) JRuby and pure Ruby?
+ Distributed locking (sharding should always be preferred, but just in case)
  + Redis, Officer, Mongo, ZK?
+ Aliases for common mixins (command handler, event listener, aggregate, processes)
