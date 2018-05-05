module SoT
  class MessageRepository
    def create_message(message)
      # persist... and return message with id
      Message.new(
        id: Time.new.to_i,
        from: message.from,
        to: message.to,
        body: message.body
      )
    end
  end
end
