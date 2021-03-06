require 'pony'

module SoT
  class Mailer
    prepend Import[
      :i18n,
      :logger,
    ]

    def initialize(server_base_url:, smtp_options: nil)
      @base_url = server_base_url
      @via = smtp_options ? :smtp : :test
      @via_options = smtp_options || {}
    end

    def send_registration_email_to_new_user(user, login_token)
      send(
        to: user.email,
        subject: i18n.t('registration_email_to_new_user.subject', scope: :mailers),
        body: i18n.t('registration_email_to_new_user.body',
                     login_token_id: login_token.id,
                     base_url: @base_url,
                     scope: :mailers),
      )
    end

    def send_info_email_about_new_user(user, message = nil)
      body = "new user: #{user.email}!"
      body += "\n\nmessage:\n#{message.body[0..200]}" if message
      send(
        to: User::ME_EMAIL,
        subject: '[Shards of Tokyo] new user!',
        body: body,
      )
    end

    def send_email_about_new_message_to_user(message)
      send(
        to: message.order.user.email,
        subject: i18n.t('email_about_new_message_to_user.subject', scope: :mailers),
        body: i18n.t('email_about_new_message_to_user.body',
                     base_url: @base_url,
                     message_body: message.body,
                     scope: :mailers),
      )
    end

    def send_email_about_new_message_to_me(message)
      send(
        to: User::ME_EMAIL,
        subject: '[Shards of Tokyo] new message!',
        body: "from user: #{message.user.email}\n\norder id: #{message.order.id}\n\nmessage: #{message.body}",
      )
    end

    def send_email_about_new_order_to_me(order)
      send(
        to: User::ME_EMAIL,
        subject: '[Shards of Tokyo] new order!',
        body: "from user: #{order.user.email}\n\norder id: #{order.id}\n\nmessage: #{order.request_text}",
      )
    end

    def send_email_with_login_token_to_user(token, user)
      send(
        to: user.email,
        subject: i18n.t('email_with_login_token_to_user.subject', scope: :mailers),
        body: i18n.t('email_with_login_token_to_user.body',
                     login_token_id: token.id,
                     base_url: @base_url,
                     scope: :mailers),
      )
    end

    def send_email_about_payment_to_user(order)
      payment = order.payments.last
      send(
        to: order.user.email,
        subject: i18n.t('email_about_payment_to_user.subject', order_id: order.id, scope: :mailers),
        body: i18n.t('email_about_payment_to_user.body',
                     order_id: order.id,
                     payment_amount: payment.price.format,
                     scope: :mailers),
      )
    end

    def send_email_about_payment_to_me(order)
      user = order.user
      payment = order.payments.last
      send(
        to: User::ME_EMAIL,
        subject: "[Shards of Tokyo] new #{payment.successful? ? 'successful' : 'failed'} payment!",
        body: "from user: #{user.email}\n\norder id: #{order.id}\n\npayment: #{payment.payment_id}\n#{payment.price.format}\n",
      )
    end

    private

    def send(to:, subject:, body:)
      mail = Pony.mail(
        from: 'mailer@shards-of-tokyo.jp',
        to: to,
        charset: 'UTF-8',
        subject: subject,
        body: body,
        via: @via,
        via_options: @via_options,
      )
      logger.debug("\n\n######################################\n\n#{mail}\n\n######################################n\n")
      logger.info("Email sent: '#{subject}' to '#{to}'")
    end
  end
end
