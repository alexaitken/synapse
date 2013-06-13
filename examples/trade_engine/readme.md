# TradeEngine

Very tiny example of an event-sourcing application, shamelessly taken from [AxonTrader](https://github.com/AxonFramework/Axon-trader).

To run the benchmark, just do the following:

    bundle install
    ruby benchmark.rb

You must have MongoDB installed in order to do the benchmark.

## Results

On my 2010 MacBook Pro (2.66 GHz Intel Core i7, 8GB DDR3 RAM):

- Ruby 1.9.3 - 575 commands/sec or 1.7 ms/command
- Ruby 2.0.0 - 496 commands/sec or 2.0 ms/command
- JRuby 1.7.4 - 396 commands/sec or 2.7 ms/command

  This should be faster in theory, but between JRuby's warmup time and the context switching
  done by the current thread pool implementation, it's not so hot. This will be fixed by
  switching to a busy-spin wait strategy and by adding a warmup to the benchmark.

  I'm also not sure of the performance of Marshal on JRuby (or MRI for that matter).

- Rubinius 22c5fbca - 326 commands/ec or 3.1 ms/command

  I'm not sure what's going on with rbx-head. I get a ton of concurrency errors due to events with a
  duplicate aggregate identifier and sequence number being appended to the event store. It seems as
  if the random number generator on rbx might be broken? Otherwise I have no explanation for this
  yet.
