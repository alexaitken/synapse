# Changelog

## 0.5.4
- Improved snapshot taker
- Increased unit test code coverage

## 0.5.3
- Fixed issue with `MarshalSerializer` and base64 encoding
- Added more definition builders for process management

## 0.5.2
- Renamed wiring to mapping, rewrote for more flexibility
- Added more definition builders
- Aggregates track event count between snapshots

## 0.5.1

- Ported most of `CommandGateway` from AxonFramework
- Expanded the number of definition builders available for configuration

## 0.5.0

- Created a configuration DSL and service container
- Created repository for non-ES aggregates called `SimpleRepository`
- Reorganized autoloading structure
- Most functionality is now ready for use
- Removed partitioning component

## 0.4.0

- Implemented a process manager
- Moved Mongo-related implementations into [synapse-mongo](https://github.com/ianunruh/synapse-mongo)

