module Synapse
  class PascalString < BinData::Primitive
    uint8 :len, :value => lambda { data.length }
    string :data, :read_length => :len

    def get
      self.data
    end

    def set(value)
      self.data = value
    end
  end
end
