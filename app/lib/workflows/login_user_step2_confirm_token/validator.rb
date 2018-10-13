module SoT
  module LoginUserStep2ConfirmToken
    class Validator
      include Import[
        :login_token_repository,
      ]

      def call(token_id)
        return Results.new([:token_not_found]) unless valid_token_exists?(token_id)

        Results.new([])
      end

      class Results < Struct.new(:errors)
        def valid?
          errors.empty?
        end
      end

      private

      def valid_token_exists?(token_id)
        !!login_token_repository.find_valid(token_id)
      end
    end
  end
end
