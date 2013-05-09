
class ActiveModelSerializer < Synapse::Serialization::Serializer

protected

  def perform_serialize(content)
    if content.is_a? Hash
      content
    else
      content.serializable_hash
    end
  end
  def perform_deserialize(content, type)
    if Hash === type
      content
    else
      deserialized = type.new
      deserialized.attributes = content
      deserialized
    end
  end
  def native_content_type
    Hash
  end
end

class OrderedHashToHashConverter
  include Synapse::Serialization::Converter

  converts BSON::OrderedHash, Hash

  def convert_content(original)
    converted = Hash.new

    original.each do |key, value|
      if value.is_a? BSON::OrderedHash
        value = convert_content value
      end

      converted[key] = value
    end

    converted
  end
end