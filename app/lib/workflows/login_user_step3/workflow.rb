module SoT
  module LoginUserStep3
    class Workflow
      include Import[
        :login_token_repository,
      ]

      def call(params)
        session_id = params[:session_id]

        token = login_token_repository.find_by(session_id: session_id)
        if token.active?
          Results.new(nil, [])
        else
          Results.new(token.user_email, [:confirmed_token_not_found])
        end
      end

      class Results < Struct.new(:user_email, :errors)
        def success?
          errors.empty?
        end
      end
    end
  end
end
