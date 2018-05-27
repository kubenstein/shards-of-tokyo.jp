module SoT
  class Event
    attr_reader :id, :name, :requester_id, :payload

    def initialize(id: nil, name:, requester_id:, payload:)
      @id = id || GenerateId.new.call
      @name = name
      @requester_id = requester_id
      @payload = payload
    end

    def self.for(event_name, obj, requester_id = 'system@shards-of-tokyo.jp')
      new(name: event_name, requester_id: requester_id, payload: Serialize.new.call(obj))
    end
  end
end
