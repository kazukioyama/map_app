class TestMailer < ApplicationMailer
  def welcome_email
    mail(to: "kazuki.oy03@gmail.com", subject: 'メールのタイトルがここに入ります')
  end
end
