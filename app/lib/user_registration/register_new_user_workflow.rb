module SoT
  module Registration
    class NewUserWorkflow
      def register(params)
        validation_results = Validator.new.validate(params)
        if validation_results.valid?
          user = create_user(params['email'])
          create_initial_message(user, params['info']) if params['info']
          send_email_to(user)
          send_email_to_me(user)
          Results.new(user.id, [])
        else
          Results.new(nil, validation_results.errors)
        end
      end

      class Results < Struct.new(:user_id, :errors)
        def success?
          errors.empty?
        end
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
