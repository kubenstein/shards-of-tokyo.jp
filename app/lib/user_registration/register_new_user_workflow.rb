module SoT
  module Registration
    class NewUserWorkflow
      def register(params)
        user = create_user(params)
        send_email_to(user)
        send_email_to_me(user)
        user
      end

      private

      def create_user(params)
        user = User.new(email: params['email'])
        UserRepository.new.create_user(user)
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
