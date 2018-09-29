module SoT
  class Event
    attr_reader :id, :name, :requester_id, :payload, :created_at

    def initialize(id:, name:, requester_id:, payload:, created_at:, **_) # rubocop:disable Metrics/ParameterLists
      @id = id
      @name = name
      @requester_id = requester_id
      @payload = payload
      @created_at = created_at
    end

    def self.build(name:, payload:, requester_id: 'system')
      new(
        id: GenerateId.new.call,
        name: name,
        requester_id: requester_id,
        payload: payload,
        created_at: Time.now,
      )
    end
  end
end
