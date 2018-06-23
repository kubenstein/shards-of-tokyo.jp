module SoT
  module LoginUserStep2
    class Workflow
      include Import[
        :login_token_repository,
        :mailer
      ]

      def call(params)
        token_id = params[:token_id]

        validation_results = Validator.new.call(token_id)
        if validation_results.valid?
          confirm_token(token_id)
          Results.new(nil, [])
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

      def confirm_token(token_id)
        login_token = login_token_repository.find(token_id)
        login_token.confirm!
        login_token_repository.save(login_token)
      end
    end
  end
end