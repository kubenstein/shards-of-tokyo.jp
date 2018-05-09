module SoT
  class CloneWithId
    def call(data_object, id = GenerateId.new.call, serializer = Serialize.new)
      attrs = serializer.call(data_object)
      attrs[:id] = id
      data_object.class.new(attrs)
    end
  end
end
