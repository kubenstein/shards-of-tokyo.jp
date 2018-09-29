module SoT
  module SubmitNewOrder
    class Workflow
      include Import[
        :user_repository,
        :order_repository,
        :mailer
      ]

      def call(params)
        user = params[:user]
        text = params[:text]

        validation_results = Validator.new.call(params)
        if validation_results.valid?
          order = create_order(user, text)
          send_email_to_me(order)
          Results.new(order, [])
        else
          Results.new(nil, validation_results.errors)
        end
      end

      class Results < Struct.new(:order, :errors)
        def order_id
          order.id
        end

        def success?
          errors.empty?
        end
      end

      private

      def create_order(from_user, text)
        order = order_repository.new_order(user: from_user)
        order.add_message(text: text, from_user: from_user)
        order_repository.create(order)
      end

      def send_email_to_me(order)
        mailer.send_email_about_new_order_to_me(order)
      end
    end
  end
end
