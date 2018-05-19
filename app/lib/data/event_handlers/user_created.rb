module SoT
  class UserCreatedEventHandler
    def call(event, state)
      user = event.payload
      state.add_resource(:users, user)
    end
  end
end
