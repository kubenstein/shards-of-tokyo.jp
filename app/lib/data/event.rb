module SoT
  class Event
    attr_reader :id, :name, :requester_id, :payload, :handler_version, :created_at

    def initialize(id:, name:, handler_version:, requester_id:, payload:, created_at:, **_)
      @id = id
      @name = name
      @requester_id = requester_id
      @payload = payload
      @handler_version = handler_version
      @created_at = created_at
    end

    def self.build(name:, handler_version:, payload:, requester_id: 'system@shards-of-tokyo.jp')
      new(
        id: GenerateId.new.call,
        name: name,
        handler_version: handler_version,
        requester_id: requester_id,
        payload: payload,
        created_at: Time.now,
      )
    end
  end
end
