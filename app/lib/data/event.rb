module SoT
  class Event < Struct.new(:name, :requester_id, :payload)
    def self.for(event_name, obj, requester_id = 'system@shards-of-tokyo.jp')
      new(event_name, requester_id, Serialize.new.call(obj))
    end
  end
end
