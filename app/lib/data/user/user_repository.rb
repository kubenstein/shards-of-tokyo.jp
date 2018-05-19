module SoT
  class UserRepository
    include Import[
      :event_store,
      :state,
    ]

    def create_user(user:, requester_id:)
      payload = Serialize.new.call(user)
      event = Event.new(EVENTS::USER_CREATED, requester_id, payload)
      event_store.add_event(event)
      user
    end

    def find_by(search_opts)
      attrs = state.get_resources(:users, search_opts)[0]
      return nil unless attrs
      User.new(attrs)
    end

    def find_me
      find_by(email: 'niewczas.jakub@gmail.com')
    end
  end
end
