module SoT
  module Registration
    class NewUserWorkflow
      include Import[
        :user_repository,
        :message_repository,
        :registration_validator,
        :mailer
      ]

      def register(params)
        email = params[:email]
        info = params[:info]
        validation_results = registration_validator.validate(email)
        if validation_results.valid?
          user = create_user(email)
          create_initial_message(user, info) if info
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
        user_repository.create(user)
      end

      def create_initial_message(from_user, message)
        me = user_repository.find_me
        message = Message.new(from_user_id: from_user.id, to_user_id: me.id, body: message)
        message_repository.create(message)
      end

      def send_email_to(user)
        mailer.send_registration_email_to_new_user(user)
      end

      def send_email_to_me(user)
        mailer.send_info_email_about_new_user(user)
      end
    end
  end
end
