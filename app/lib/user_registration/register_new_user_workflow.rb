module SoT
  module Registration
    class NewUserWorkflow
      def register(params)
        user = create_user(params)
        send_email_to(user)
        send_email_to_me(user)
      end

      private

      def create_user(params)
        user = User.new(email: params['email'])
        UserRepository.new.create_user(user)
      end

      def send_email_to(user)
        # send email..
      end

      def send_email_to_me(user)
        # send email..
      end
    end
  end
end
