module SoT
  class Event < Struct.new(:name, :requester_id, :payload)
  end
end
