# TODO

## Immediate

+ Configuration DSL for process management
  + `MappingProcessManager`
  + `MongoProcessRepository`
+ Base64 encoding for `MarshalSerializer`
+ Deferred snapshot taker (using `Thread::Pool` or similar)

## Odds and ends

+ Simplified mixins for domain commands and events
  + For serialization, validation, building, etc.
+ Disruptor for command bus (??) JRuby and pure Ruby?
+ Distributed locking (sharding should always be preferred, but just in case)
  + Redis, Officer, Mongo, ZK?
+ Aliases for common mixins (command handler, event listener, aggregate, processes)

## AxonFramework functionality

+ ~~Auditing component~~
+ Command bus
  + ~~DSL for defining and subscribing command handlers to command types~~
  + ~~Command validation (ActiveModel)~~
  + ~~Asynchronous command bus~~
  + Instrumentation for command buses
  + ~~Command gateway~~
  + Abstraction of aggregate load/store (plus aggregate target DSL)
  + ~~Rollback policies~~
+ Event handling
  + Listener groups and group bus
  + Asynchronous event bus
  + Distributed event bus (AMQP)
  + ~~DSL for defining and mapping event handlers to event types~~
  + Instrumentation for event buses (Graphite, Ganglia, etc.)
  + Event replay framework
  + Event scheduling framework (Quartz-like)
+ Event sourcing
  + ~~Snapshot support~~
  + ~~Conflict resolution support~~
  + Caching repository
  + Hybrid ES repository
+ Event store
  + Management
+ Process management
  + ~~Core interfaces~~
  + ~~Implementation~~
  + ~~Mapping processes~~
  + Asynchronous process management
+ Serialization
  + ~~Hash serializer~~
  + Nokogiri serializer

## Integration

+ Mongo
  + ~~Event store~~
  + ~~Process repository~~
+ Sequel
  + Event store
  + Process repository

## Lokad.CQRS functionality

+ ~~Message de-duplication~~
+ Engine processes
+ Message quarantine
+ Partitioning
  + Queue reader/writer abstraction
  + JSON/BSON/MsgPack message packing
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
