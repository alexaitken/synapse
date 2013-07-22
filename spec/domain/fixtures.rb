module Synapse
  module Domain

    class Person
      include AggregateRoot

      attr_reader :id, :name

      def initialize(id, name)
        @id, @name = id, name
      end

      def change_name(name)
        @name = name
        publish_event NameChangedEvent.new(id, name)
      end

      def delete
        mark_deleted
      end
    end

    class NameChangedEvent
      attr_reader :id, :name
      def initialize(id, name)
        @id, @name = id, name
      end
    end

  end
end