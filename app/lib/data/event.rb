module SoT
  class Event
    attr_reader :id, :name, :requester_id, :payload, :version

    def initialize(id: nil, name:, version:, requester_id: 'system@shards-of-tokyo.jp', payload:)
      @id = id || GenerateId.new.call
      @name = name
      @requester_id = requester_id
      @payload = payload
      @version = version
    end
  end
end
