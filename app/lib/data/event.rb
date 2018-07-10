module SoT
  class Event
    attr_reader :id, :name, :requester_id, :payload, :version, :created_at

    def initialize(id:, name:, version:, requester_id:, payload:, created_at:, **_)
      @id = id
      @name = name
      @requester_id = requester_id
      @payload = payload
      @version = version
      @created_at = created_at
    end

    def self.build(name:, version:, payload:)
      new(
        id: GenerateId.new.call,
        name: name,
        version: version,
        requester_id: 'system@shards-of-tokyo.jp',
        payload: payload,
        created_at: Time.now,
      )
    end
  end
end
