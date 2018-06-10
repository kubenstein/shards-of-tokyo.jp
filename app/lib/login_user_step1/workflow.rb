module SoT
  module LoginUserStep1
    class Workflow
      include Import[
        :user_repository,
        :login_token_repository,
        :mailer
      ]

      def call(params)
        email = params[:email]
        session_id = params[:session_id]

        validation_results = Validator.new.call(params)
        if validation_results.valid?
          user = user_repository.find_by(email: email)
          token = ganerate_login_token(user, session_id)
          send_email_with_login_token_to_user(token, user)
          Results.new(token, [])
        else
          Results.new(nil, validation_results.errors)
        end
      end

      class Results < Struct.new(:token, :errors)
        def success?
          errors.empty?
        end
      end

      private

      def ganerate_login_token(user, session_id)
        login_token = login_token_repository.new_login_token(user.id, session_id)
        login_token_repository.create(login_token)
      end

      def send_email_with_login_token_to_user(token, user)
        mailer.send_email_with_login_token_to_user(token, user)
      end
    end
  end
end
