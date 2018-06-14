module SoT
  module AddOrderMessage
    class Workflow
      include Import[
        :order_repository,
        :user_repository,
        :mailer
      ]

      def call(params)
        user = params[:user]
        order_id = params[:order_id]
        text = params[:text]

        validation_results = Validator.new.call(params)
        if validation_results.valid?
          message = create_order_message(text: text, user: user, order_id: order_id)
          if message.from_user?
            send_email_to_me(message)
          else
            send_email_to_user(message)
          end

          Results.new(order_id, [])
        else
          Results.new(order_id, validation_results.errors)
        end
      end

      class Results < Struct.new(:order_id, :errors)
        def success?
          errors.empty?
        end
      end

      private

      def create_order_message(text:, user:, order_id:)
        order = order_repository.find(order_id)
        message = order.add_message(text: text, from_user: user)
        order_repository.save(order)
        message
      end

      def send_email_to_user(message)
        mailer.send_email_about_new_message_to_user(message)
      end

      def send_email_to_me(message)
        mailer.send_email_about_new_message_to_me(message)
      end
    end
  end
end
