require 'pony'

module SoT
  class Mailer
    prepend Import[
      :i18n,
      :logger,
    ]

    def initialize(smtp_options: nil)
      @via = smtp_options ? :smtp : :test
      @via_options = smtp_options || {}
    end

    def send_registration_email_to_new_user(user, login_token)
      send(
        to: user.email,
        subject: i18n.t('registration_email_to_new_user.subject', scope: :mailers),
        body: i18n.t('registration_email_to_new_user.body', login_token_id: login_token.id, scope: :mailers),
      )
    end

    def send_info_email_about_new_user(user)
      send(
        to: 'niewczas.jakub@gmail.com',
        subject: '[Shards of Tokyo] new user!',
        body: "new user: #{user.email}!",
      )
    end

    def send_email_about_new_message_to_user(message)
      send(
        to: message.user.email,
        subject: i18n.t('email_about_new_message_to_user.subject', scope: :mailers),
        body: i18n.t('email_about_new_message_to_user.body', message_body: message.body, scope: :mailers),
      )
    end

    def send_email_about_new_message_to_me(message)
      send(
        to: 'niewczas.jakub@gmail.com',
        subject: '[Shards of Tokyo] new message!',
        body: "from user: #{message.user.email}\n\norder id: #{message.order.id}\n\nmessage: #{message.body}",
      )
    end

    def send_email_about_new_order_to_me(order)
      send(
        to: 'niewczas.jakub@gmail.com',
        subject: '[Shards of Tokyo] new order!',
        body: "from user: #{order.user.email}\n\norder id: #{order.id}\n\nmessage: #{order.request_text}",
      )
    end

    def send_email_with_login_token_to_user(token, user)
      send(
        to: user.email,
        subject: i18n.t('email_with_login_token_to_user.subject', scope: :mailers),
        body: i18n.t('email_with_login_token_to_user.body', login_token_id: token.id, scope: :mailers),
      )
    end

    def send_email_about_payment_to_user(order)
      payment = order.payments.last
      send(
        to: order.user.email,
        subject: i18n.t('email_about_payment_to_user.subject', order_id: order.id, scope: :mailers),
        body: i18n.t('email_about_payment_to_user.body',
                     order_id: order.id,
                     payment_amount: payment.amount,
                     payment_currency: payment.currency,
                     scope: :mailers),
      )
    end

    def send_email_about_payment_to_me(order)
      user = order.user
      payment = order.payments.last
      send(
        to: 'niewczas.jakub@gmail.com',
        subject: '[Shards of Tokyo] new payment!',
        body: "from user: #{user.email}\n\norder id: #{order.id}\n\npayment: #{payment.payment_id}\n#{payment.amount}#{payment.currency}\n",
      )
    end

    private

    def send(to:, subject:, body:)
      mail = Pony.mail(
        from: 'mailer@shards-of-tokyo.jp',
        to: to,
        subject: subject,
        body: body,
        via: @via,
        via_options: @via_options,
      )
      logger.debug(mail.to_s)
      logger.info("Email sent: '#{subject}' to '#{to}'")
    end
  end
end
