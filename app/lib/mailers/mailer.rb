require 'pony'

module SoT
  class Mailer
    def send_registration_email_to_new_user(user)
      send(
        to: user.email,
        subject: 'Welcome to Shards of Tokyo',
        body: "Hello!\n\nThank you for creating an account at Shards of Tokyo, I really appreciate this and welcome you personally.\n\nShards of Tokyo is made for positive people fascinated by Japan and Japanese culture. I want to share a shard of my own happiness with other people by helping importing all kind of stuff. As I love receiving physical, touchable, tastable, readable, joyable, memorable gifts myself please feel free to contact me whenever there is anything you wish to receive specially for you, directly from Japan!\n\nYou can go to http://shards-of-tokyo.jp/dashboard at anytime to place a new request or to check those that are already ongoing.\n\nAll notifications will be sent on that email address.\n\nStay tuned,\n\nSoT"
      )
    end

    def send_info_email_about_new_user(user)
      send(
        to: 'niewczas.jakub@gmail.com',
        subject: '[Shards of Tokyo] new user!',
        body: "new user: #{user.email}!"
      )
    end

    private

    def send(to:, subject:, body:)
      Pony.mail(
        from: 'mailer@shards-of-tokyo.jp',
        to: to,
        subject: subject,
        body: body,
        via: :test
      )
    end
  end
end
