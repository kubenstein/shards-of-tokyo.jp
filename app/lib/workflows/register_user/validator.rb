module SoT
  module RegisterUser
    class Validator
      include Import[
        :user_repository
      ]

      def call(params)
        email = params[:email]
        session_id = params[:session_id]

        return Results.new([:empty_session_id]) if session_id.to_s.empty?
        return Results.new([:email_invalid]) unless email.include?('@')
        return Results.new([:email_taken]) if email_taken?(email)

        Results.new([])
      end

      class Results < Struct.new(:errors)
        def valid?
          errors.empty?
        end
      end

      private

      def email_taken?(email)
        user_repository.exists?(email: email)
      end
    end
  end
end
