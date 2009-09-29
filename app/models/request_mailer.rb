class RequestMailer < ActionMailer::Base


  def release_notice(request)
    recipients  request.requestors.may('review').map { |u| "#{u.name} <#{u.email}>" }
    from        "#{request.contact_name} <#{request.contact_email}>"
    subject     "You may now review #{request}"
    sent_on     Time.now
    body        :request => request
  end

end

