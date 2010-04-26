class RequestMailer < ActionMailer::Base
  def started_reminder(request)
    recipients  request.requestors.may('update').map { |u| "#{u.name} <#{u.email}>" }
    from        "#{request.contact_name} <#{request.contact_email}>"
    subject     "Your #{request} needs attention"
    sent_on     Time.now
    body        :request => request
  end

  def completed_reminder(request)
    recipients  request.requestors.may('approve').map { |u| "#{u.name} <#{u.email}>" }
    from        "#{request.contact_name} <#{request.contact_email}>"
    subject     "Your #{request} needs approval"
    sent_on     Time.now
    body        :request => request
  end

  def release_notice(request)
    recipients  request.requestors.may('review').map { |u| "#{u.name} <#{u.email}>" }
    from        "#{request.contact_name} <#{request.contact_email}>"
    subject     "You may now review #{request}"
    sent_on     Time.now
    body        :request => request
  end

end

