module SoT
  module Registration
    class NewUserWorkflow
      def register(params)
        user = create_user(params['email'])
        create_initial_message(user, params['info']) if params['info']
        send_email_to(user)
        send_email_to_me(user)
        user
      end

      private

      def create_user(email)
        user = User.new(email: email)
        UserRepository.new.create_user(user)
      end

      def create_initial_message(from_user, message)
        me = UserRepository.new.find_me
        message = Message.new(from_user_id: from_user.id, to_user_id: me.id, body: message)
        MessageRepository.new.create_message(message)
      end

      def send_email_to(user)
        Mailer.new.send_registration_email_to_new_user(user)
      end

      def send_email_to_me(user)
        Mailer.new.send_info_email_about_new_user(user)
      end
    end
  end
end
