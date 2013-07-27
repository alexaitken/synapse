module Synapse
  class MessageRecordType
    COMMAND = 0
    EVENT = 1
    DOMAIN_EVENT = 2

    def self.from_class(klass)
      if klass == Command::CommandMessage
        COMMAND
      elsif klass == Domain::DomainEventMessage
        DOMAIN_EVENT
      else
        EVENT
      end
    end
  end

  class MessageRecord < BinData::Record
    endian :big

    bit4 :type

    pascal_string :id

    pascal_string :metadata
    pascal_string :payload
    pascal_string :payload_type
    pascal_string :payload_revision

    double :timestamp

    pascal_string :aggregate_id, :onlyif => :domain_event?
    uint8 :sequence_number, :onlyif => :domain_event?

    def command?
      type == MessageRecordType::COMMAND
    end

    def domain_event?
      type == MessageRecordType::DOMAIN_EVENT
    end

    def event?
      type == MessageRecordType::EVENT
    end
  end
end
