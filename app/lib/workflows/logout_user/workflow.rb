module SoT
  module LogoutUser
    class Workflow
      include Import[
        :login_token_repository,
      ]

      def call(params)
        session_id = params[:session_id]
        invalidate_token(session_id)
        Results.new
      end

      class Results
        def success?
          true
        end
      end

      private

      def invalidate_token(session_id)
        login_token_repository.find_all_by(session_id: session_id).each do |token|
          token.invalidate!
          login_token_repository.save(token)
        end
      end
    end
  end
end
