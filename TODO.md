## Soon

### Bugs
+ Improve deadlock detection in `IdentifierLock` -- it's very fragile at the moment

### Still to be ported
+ De-duplication filter
+ Validation filter

### Enhancements
+ Write more specs for `Router` component
+ Write spec for `SimpleEventBus`
+ Write specs for `RoutedCommandHandler`, `RoutedEventListener`
+ Improve encapsulation on `EventSourcingRepository`
+ Get YARD to properly document `AbstractType` and `abstract_method`
+ Improve the following exception messages:

  + `AggregateNotFoundError`
  + `AggregateDeletedError`
  + `StreamNotFoundError`
  + `ConcurrencyError`
  + `ConflictingAggregateVersionError`
  + `DeadlockError`

+ Change `MessageRouter#handler_for` to `first`/`first!`
+ Figure out if Inflecto can be used instead of copied inflection methods from ActiveSupport
+ Move `ReentrantLock` to Contender, write additional specs

### New features
+ Find a suitable caching library and re-implement `CachingEventSourcingRepository`
+ Implement an in-memory event store for integration tests
+ Implement a serializer using Protobuf
+ Implement an `EventPublisher` that provides simple access to an event bus
