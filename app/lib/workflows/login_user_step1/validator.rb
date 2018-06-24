module SoT
  module LoginUserStep1
    class Validator
      include Import[
        :user_repository,
      ]

      def call(params)
        email = params[:email]
        session_id = params[:session_id]

        return Results.new([:empty_email]) if email.to_s.empty?
        return Results.new([:empty_session_id]) if session_id.to_s.empty?
        return Results.new([:email_not_found]) unless user_exists?(email)

        Results.new([])
      end

      class Results < Struct.new(:errors)
        def valid?
          errors.empty?
        end
      end

      private

      def user_exists?(email)
        user_repository.exists?(email: email)
      end
    end
  end
end
