module SoT
  module AddOrderMessage
    class Validator
      include Import[
        :order_repository
      ]

      def call(params)
        return Results.new([:order_not_found]) unless can_user_post_to_order?(params[:order_id], params[:user])
        return Results.new([:empty_text]) if params[:text].to_s.empty?

        Results.new([])
      end

      class Results < Struct.new(:errors)
        def valid?
          errors.empty?
        end
      end

      private

      def can_user_post_to_order?(order_id, user)
        return false if order_id.to_s.empty? || user.to_s.empty?
        return true if user.me?

        order_repository.exists?(id: order_id, user_id: user.id)
      end
    end
  end
end
