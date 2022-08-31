class CalendarsController < ApplicationController
  def index
  end

  def mail
    TestMailer.welcome_email.deliver
  end
end
