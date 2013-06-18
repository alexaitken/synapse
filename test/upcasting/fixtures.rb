module Synapse
  module Upcasting
    class TestSplitUpcaster < Upcaster

      expects_content_type Object

      def can_upcast?(serialized_type)
        serialized_type.name == 'TestEvent' and serialized_type.revision == '2'
      end

      def upcast(intermediate, expected_types, upcast_context)
        upcast_objects = Array.new

        expected_types.each do |type|
          upcast_objects.push Serialization::SerializedObject.new(intermediate.content, Object, type)
        end

        upcast_objects
      end

      def upcast_type(serialized_type)
        upcast_types = Array.new
        upcast_types.push Serialization::SerializedType.new('FooEvent', '1')
        upcast_types.push Serialization::SerializedType.new('BazEvent', '1')
        upcast_types.push Serialization::SerializedType.new('BarEvent', '1')
        upcast_types
      end
    end

    class TestTypeUpcaster < SingleUpcaster
      expects_content_type Object

      def can_upcast?(serialized_type)
        serialized_type.name == 'TestEvent' and serialized_type.revision == '1'
      end

    protected

      def perform_upcast(intermediate, upcast_context)
        intermediate.content
      end

      def perform_upcast_type(serialized_type)
        Serialization::SerializedType.new('TestEvent', '2')
      end
    end

    class TestPhaseOutUpcaster < SingleUpcaster
      expects_content_type Object

      def can_upcast?(serialized_type)
        serialized_type.name == 'BazEvent' and serialized_type.revision == '1'
      end

    protected

      def perform_upcast(intermediate, upcast_context); end
      def perform_upcast_type(serialized_type); end
    end
  end
end
