module Synapse
  module UnitOfWork

    class NullTransactionManager < TransactionManager
      TX = Object.new

      def start
        TX
      end

      def commit(tx); end
      def rollback(tx); end
    end

    class TestUnitListener
      include UnitListener
    end

    class MockError < RuntimeError; end

    class StubAggregate
      attr_reader :id
      attr_reader :listeners

      def initialize(id)
        @id = id
        @listeners = Array.new
      end

      def add_registration_listener(&block)
        @listeners.push block
      end
    end

    class StubOuterUnit
      def self.start
        unit = new
        unit.start

        unit
      end

      def initialize
        @listeners = UnitListenerList.new
      end

      def start
        CurrentUnit.set self
      end

      def commit
        @listeners.after_commit self
      ensure
        clear
      end

      def rollback
        @listeners.on_rollback self, nil
        @listeners.on_cleanup self
      ensure
        clear
      end

      def register_listener(listener)
        @listeners.push listener
      end

      private

      def clear
        CurrentUnit.clear self
      end
    end

  end
end
