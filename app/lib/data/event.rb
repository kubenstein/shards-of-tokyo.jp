module SoT
  class Event
    attr_reader :id, :name, :requester_id, :payload

    def initialize(id: nil, name:, requester_id: 'system@shards-of-tokyo.jp', payload:)
      @id = id || GenerateId.new.call
      @name = name
      @requester_id = requester_id
      @payload = payload
    end
  end
end
