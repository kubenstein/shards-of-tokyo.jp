require 'pony'

module SoT
  class Mailer
    def initialize(smtp_options: nil)
      @via = smtp_options ? :smtp : :test
      @via_options = smtp_options || {}
    end

    def send_registration_email_to_new_user(user)
      send(
        to: user.email,
        subject: 'Welcome to Shards of Tokyo',
        body: "Hello!\n\nThank you for creating an account at Shards of Tokyo, I really appreciate this and welcome you personally.\n\nShards of Tokyo is made for positive people fascinated by Japan and Japanese culture. I want to share a shard of my own happiness with other people by helping importing all kind of stuff. As I love receiving physical, touchable, tastable, readable, joyable, memorable gifts myself please feel free to contact me whenever there is anything you wish to receive specially for you, directly from Japan!\n\nYou can go to http://shards-of-tokyo.jp/orders at anytime to place a new request or to check those that are already ongoing.\n\nAll notifications will be sent on that email address.\n\nStay tuned,\n\nSoT"
      )
    end

    def send_info_email_about_new_user(user)
      send(
        to: 'niewczas.jakub@gmail.com',
        subject: '[Shards of Tokyo] new user!',
        body: "new user: #{user.email}!"
      )
    end

    def send_email_about_new_message_to_user(message)
      send(
        to: message.user.email,
        subject: '[Shards of Tokyo] new message!',
        body: "message: #{message.body}"
      )
    end

    def send_email_about_new_message_to_me(message)
      send(
        to: 'niewczas.jakub@gmail.com',
        subject: '[Shards of Tokyo] new message!',
        body: "from user: #{message.user.email}\n\norder id: #{message.order.id}\n\nmessage: #{message.body}"
      )
    end

    def send_email_about_new_order_to_me(order)
      send(
        to: 'niewczas.jakub@gmail.com',
        subject: '[Shards of Tokyo] new order!',
        body: "from user: #{order.user.email}\n\norder id: #{order.id}\n\nmessage: #{order.request_text}"
      )
    end

    def send_email_with_login_token_to_user(token, user)
      send(
        to: user.email,
        subject: '[Shards of Tokyo] login link',
        body: "Hello!\n\nBy clicking link below you will be automatically log in on device you asked for login\n\n http://shards-of-tokyo.jp/login/accept_link_from_email?token_id=#{token.id} \n\nCheers,\n\nSoT"
      )
    end

    def send_email_about_payment_to_user(order)
      payment = order.payments.last
      send(
        to: order.user.email,
        subject: "[Shards of Tokyo] order #{order.id} payment!",
        body: "Hello!\n\nThis email is a confirmation of your payment at Shards of Tokyo.\nPayment details:\norder: ${order.id}\namount: #{payment.amount}#{payment.currency}\n\nI will take care of the delivery process and will inform you about any updates.\nThank you so much!\nSoT"
      )
    end

    def send_email_about_payment_to_me(order)
      user = order.user
      payment = order.payments.last
      send(
        to: 'niewczas.jakub@gmail.com',
        subject: '[Shards of Tokyo] new payment!',
        body: "from user: #{user.email}\n\norder id: #{order.id}\n\npayment: #{payment.payment_id}\n#{payment.amount}#{payment.currency}\n"
      )
    end

    private

    def send(to:, subject:, body:)
      Pony.mail(
        from: 'mailer@shards-of-tokyo.jp',
        to: to,
        subject: subject,
        body: body,
        via: @via,
        via_options: @via_options
      )
    end
  end
end
