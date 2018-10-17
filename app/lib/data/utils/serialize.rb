module SoT
  class Serialize
    def call(data_object)
      return data_object.serialize if data_object.respond_to?(:serialize)
      DefaultSerializer.new.call(data_object)
    end
  end

  class DefaultSerializer
    def call(data_object)
      data_object
        .instance_variables
        .reject { |attr_name| attr_name[1] == '_' }
        .each_with_object({}) do |attr_name_raw, hash|
          attr_name = attr_name_raw.to_s.delete('@').to_sym
          data = data_object.instance_variable_get(attr_name_raw)
          hash[attr_name] = data.is_a?(Hash) ? data.to_json : data
        end
    end
  end
end
