class RequestMailer < ActionMailer::Base
  def started_reminder(request)
    recipients  request.users.for_perspective(Edition::PERSPECTIVES.first).map { |u| "#{u.name} <#{u.email}>" }
    from        "#{request.contact_name} <#{request.contact_email}>"
    subject     "#{request} needs attention"
    sent_on     Time.now
    body        :request => request
  end

  def completed_reminder(request)
    recipients  request.users.unfulfilled(Approver.quantity_null).map { |u| "#{u.name} <#{u.email}>" }
    from        "#{request.contact_name} <#{request.contact_email}>"
    subject     "#{request} needs your approval"
    sent_on     Time.now
    body        :request => request
  end

  def release_notice(request)
    recipients  request.users.for_perspective(Edition::PERSPECTIVES.first).map { |u| "#{u.name} <#{u.email}>" }
    from        "#{request.contact_name} <#{request.contact_email}>"
    subject     "You may now review #{request}"
    sent_on     Time.now
    body        :request => request
  end

end

