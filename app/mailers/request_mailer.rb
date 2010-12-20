class RequestMailer < ActionMailer::Base

  helper :application

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
      :to => request.users.unfulfilled( Approver.where( :quantity => nil ) ).map(&:to_email),
      :from => request.contact_to_email,
      :subject => "#{request} needs your approval"
    )
  end

  def submitted_notice( request )
    @request = request
    mail(
      :to => request.users.for_perspective(Edition::PERSPECTIVES.first).map(&:to_email),
      :from => request.contact_to_email,
      :subject => "#{request} has been submitted"
    )
  end

  def accepted_notice( request )
    @request = request
    mail(
      :to => request.users.for_perspective(Edition::PERSPECTIVES.first).map(&:to_email),
      :from => request.contact_to_email,
      :subject => "#{request} has been accepted for review"
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

