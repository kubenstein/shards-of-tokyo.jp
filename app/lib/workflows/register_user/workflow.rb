module SoT
  module RegisterUser
    class Workflow
      include Import[
        :user_repository,
        :order_repository,
        :mailer
      ]

      def call(params)
        email = params[:email]
        info = params[:info]
        validation_results = Validator.new.call(email)
        if validation_results.valid?
          user = create_user(email)
          create_initial_message(user, info) if info
          send_email_to(user)
          send_email_to_me(user)
          Results.new(user.id, [])
        else
          Results.new(nil, validation_results.errors)
        end
      end

      class Results < Struct.new(:user_id, :errors)
        def success?
          errors.empty?
        end
      end

      private

      def create_user(email)
        user_repository.create(
          user_repository.new_user(email: email),
        )
      end

      def create_initial_message(from_user, message)
        order = order_repository.new_order(user: from_user)
        order.add_message(text: message, from_user: from_user)
        order_repository.create(order)
      end

      def send_email_to(user)
        mailer.send_registration_email_to_new_user(user)
      end

      def send_email_to_me(user)
        mailer.send_info_email_about_new_user(user)
      end
    end
  end
end
