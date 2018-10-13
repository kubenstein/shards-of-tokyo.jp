module SoT
  module LoginUserStep3
    class Workflow
      include Import[
        :login_token_repository,
      ]

      def call(params)
        session_id = params[:session_id]

        token = login_token_repository.find_by(session_id: session_id)
        return Results.new(nil, [:token_not_found]) unless token
        return Results.new(token, [:token_not_active]) unless token.active?
        Results.new(token, [])
      end

      class Results < Struct.new(:token, :errors)
        def user_email
          return '' unless token
          token.user_email
        end

        def success?
          errors.empty?
        end
      end
    end
  end
end
