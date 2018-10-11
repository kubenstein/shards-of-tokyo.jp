module SoT
  module RegisterUser
    class Workflow
      include Import[
        :user_repository,
        :order_repository,
        :login_token_repository,
        :mailer
      ]

      def call(params)
        email = params[:email]
        info = params[:info]
        session_id = params[:session_id]

        validation_result = Validator.new.call(params)
        if validation_result.valid?
          user = create_user(email)
          create_initial_message(user, info) unless info.to_s.empty?
          login_token = create_login_token_for_user(user, session_id)
          send_email_to_user(user, login_token)
          send_email_to_me(user)
          Results.new(user, [])
        else
          Results.new(nil, validation_result.errors)
        end
      end

      class Results < Struct.new(:user, :errors)
        def user_id
          user.id
        end

        def success?
          errors.empty?
        end
      end

      private

      def create_user(email)
        user_repository.create(
          user_repository.new_user(email: email),
        )
      end

      def create_initial_message(from_user, message)
        order = order_repository.new_order(user: from_user)
        order.add_message(text: message, from_user: from_user)
        order_repository.create(order)
      end

      def create_login_token_for_user(user, session_id)
        login_token_repository.new_login_token(user, session_id).tap do |login_token|
          login_token_repository.create(login_token)
        end
      end

      def send_email_to_user(user, login_token)
        mailer.send_registration_email_to_new_user(user, login_token)
      end

      def send_email_to_me(user)
        mailer.send_info_email_about_new_user(user)
      end
    end
  end
end
