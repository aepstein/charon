class RequestMailer < ActionMailer::Base
  def started_reminder(request)
    @request = request
    mail(
      :to => request.users.for_perspective(Edition::PERSPECTIVES.first).map(&:to_email),
      :from => request.contact_to_email,
      :subject => "#{request} needs attention"
    )
  end

  def completed_reminder(request)
    @request = request
    mail(
      :to => request.users.unfulfilled(Approver.quantity_null).map(&:to_email),
      :from => request.contact_to_email,
      :subject => "#{request} needs your approval"
    )
  end

  def release_notice(request)
    @request = request
    mail(
      :to => request.users.for_perspective(Edition::PERSPECTIVES.first).map(&:to_email),
      :from => request.contact_to_email,
      :subject => "You may now review #{request}"
    )
  end

end

