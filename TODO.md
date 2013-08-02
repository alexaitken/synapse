# TODO

## Immediate

+ [EventBus] More cluster selector implementations
+ Thread-safety review
  + [x] Auditing
  + [x] Command
  + [_] Common
  + [x] Domain
  + [x] EventBus
  + [_] EventSourcing
  + [X] EventStore
  + [_] Mapping
  + [X] Repository
  + [_] Saga
  + [_] Serialization
  + [_] UnitOfWork
  + [_] Upcasting

## In flux with Contender

+ Replace mutable structures with copy-on-write implementations
+ Implement a retry scheduler provider using `ScheduledPoolExecutor`
+ Test `ScheduledPoolExecutor` with aggregate snapshot taker
+ Create event scheduler using `ScheduledPoolExecutor`
+ Rewrite some of the locking mechanisms using `ReentrantLock`

## AxonFramework functionality

+ Command bus
  + Instrumentation for command buses (Graphite, Ganglia, etc.)
  + Abstraction of aggregate load/store (plus aggregate target DSL)
+ Event handling
  + Asynchronous event bus
  + Distributed event bus (AMQP)
  + Instrumentation for event buses (Graphite, Ganglia, etc.)
  + Event replay framework
  + Event scheduler interface
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
+ Projections
  + In-memory projections or serialized projections
+ Dashboard
  + Projection management and replay
  + Domain auditing
    + Command -> events correlation
    + Command dispatch failures
+ DSL for defining event and command contracts

## Odds and ends

+ Better serialization framework (external, would be able to handle transient properties, etc.)
+ Simplified mixins for domain commands and events
  + For serialization, validation, building, etc.
+ Disruptor for command bus (??) JRuby and pure Ruby?
+ Distributed locking (sharding should always be preferred, but just in case)
  + Redis, Officer, Mongo, ZK?
+ Aliases for common mixins (command handler, event listener, aggregate, processes)
