module SoT
  class Serialize
    def call(data_object)
      data_object
        .instance_variables
        .reject { |attr_name| attr_name[1] == '_'}
        .each_with_object({}) do |attr_name, hash|
          hash[attr_name.to_s.gsub('@', '').to_sym] = data_object.instance_variable_get(attr_name)
        end
    end
  end
end
