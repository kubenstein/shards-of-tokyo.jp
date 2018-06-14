module SoT
  module RegisterUser
    class Validator
      include Import[
        :user_repository
      ]

      def call(email)
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
        !!user_repository.find_by(email: email)
      end
    end
  end
end
