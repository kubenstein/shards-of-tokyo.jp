module SoT
  module LoginUserStep2
    class Workflow
      include Import[
        :login_token_repository,
        :mailer
      ]

      def call(params)
        token_id = params[:token_id]

        validation_result = Validator.new.call(token_id)
        if validation_result.valid?
          token = confirm_token(token_id)
          Results.new(token, [])
        else
          Results.new(nil, validation_result.errors)
        end
      end

      class Results < Struct.new(:token, :errors)
        def success?
          errors.empty?
        end

        def session_id
          token.session_id
        end
      end

      private

      def confirm_token(token_id)
        login_token_repository.find(token_id).tap do |login_token|
          login_token.confirm!
          login_token_repository.save(login_token)
        end
      end
    end
  end
end
