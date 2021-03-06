module SoT
  module LoginUserStep1SendToken
    class Workflow
      include Import[
        :user_repository,
        :login_token_repository,
        :mailer
      ]

      def call(params)
        email = params[:email]
        session_id = params[:session_id]

        validation_result = Validator.new.call(params)
        if validation_result.valid?
          user = user_repository.find_by(email: email)
          token = generate_login_token(user, session_id)
          send_email_with_login_token_to_user(token, user)
          Results.new(token, [])
        else
          Results.new(nil, validation_result.errors)
        end
      end

      class Results < Struct.new(:token, :errors)
        def success?
          errors.empty?
        end
      end

      private

      def generate_login_token(user, session_id)
        login_token = login_token_repository.new_login_token(user, session_id)
        login_token_repository.create(login_token)
      end

      def send_email_with_login_token_to_user(token, user)
        mailer.send_email_with_login_token_to_user(token, user)
      end
    end
  end
end
