# Changelog

## 0.5.6 (2013-06-18)

- Exposed message context to mapped message handlers (events, commands)

## 0.5.5 (2013-06-13)

- Changed some of the API for configuration framework
- Added simple Rails integration
- Switched to [contender](https://github.com/ianunruh/contender) for concurrency
- Switched to [test-unit](https://github.com/test-unit/test-unit) for testing

## 0.5.4 (2013-06-05)

- Improved snapshot taker
- Increased unit test code coverage

## 0.5.3 (2013-06-03)
- Fixed issue with `MarshalSerializer` and base64 encoding
- Added more definition builders for process management

## 0.5.2 (2013-06-03)

- Renamed wiring to mapping, rewrote for more flexibility
- Added more definition builders
- Aggregates track event count between snapshots

## 0.5.1 (2013-05-31)

- Ported most of `CommandGateway` from AxonFramework
- Expanded the number of definition builders available for configuration

## 0.5.0 (2013-05-28)

- Created a configuration DSL and service container
- Created repository for non-ES aggregates called `SimpleRepository`
- Reorganized autoloading structure
- Most functionality is now ready for use
- Removed partitioning component

## 0.4.0 (2013-05-13)

- Implemented a process manager
- Moved Mongo-related implementations into [synapse-mongo](https://github.com/ianunruh/synapse-mongo)
