module SoT
  module AddOrderMessage
    class Validator
      include Import[
        :order_repository
      ]

      def call(params)
        return Results.new([:order_not_found]) unless order_belongs_to_user?(params[:order_id], params[:user_id])
        return Results.new([:empty_text]) if params[:text].to_s.empty?

        Results.new([])
      end

      class Results < Struct.new(:errors)
        def valid?
          errors.empty?
        end
      end

      private

      def order_belongs_to_user?(order_id, user_id)
        return false if order_id.to_s.empty? || user_id.to_s.empty?
        order_repository.find(order_id).user.id == user_id
      end
    end
  end
end
