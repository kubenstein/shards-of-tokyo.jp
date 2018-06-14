module SoT
  Event::USER_CREATED = 'user_created'
  
  class UserCreatedEventHandler
    def call(event, state)
      user = event.payload
      state.add_resource(:users, user)
    end
  end
end
