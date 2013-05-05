# TODO

+ Auditing component
+ Command bus
  + DSL for defining and subscribing command handlers to command types
  + ~~Command validation (ActiveModel)~~
  + Asynchronous command bus
  + Command gateway
  + Abstraction of aggregate load/store
  + ~~Rollback policies~~
+ Event handling
  + Clustered event bus
  + Asynchronous event bus
  + Distributed event bus (AMQP)
  + DSL for defining and mapping event handlers to event types
  + Metrics for event buses (Graphite, Ganglia, etc.)
  + Event replay framework
  + Event scheduling framework (Quartz-like)
+ Event sourcing
  + ~~Snapshot support~~
  + Conflict resolution support
  + Caching repository
  + Hybrid event storage
+ Event store
  + Persistent implementations (management, DataMapper, ActiveRecord, MongoMapper, etc.)
+ Repository
  + Optimistic/pessimistic lock manager

TODO Finish this TODO list