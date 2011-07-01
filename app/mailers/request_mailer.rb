class RequestMailer < ActionMailer::Base

  helper :application

  def started_notice(request)
    @request = request
    mail(
      :to => request.users.for_perspective(Edition::PERSPECTIVES.first).map(&:to_email),
      :from => request.contact_to_email,
      :subject => "#{request} needs attention"
    )
  end

  def completed_notice(request)
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

  def released_notice(request)
    @request = request
    mail(
      :to => request.users.for_perspective(Edition::PERSPECTIVES.first).map(&:to_email),
      :from => request.contact_to_email,
      :subject => "You may now review #{request}"
    )
  end

  def rejected_notice(request)
    @request = request
    mail(
      :to => request.users.for_perspective(Edition::PERSPECTIVES.first).map(&:to_email),
      :from => request.contact_to_email,
      :subject => "#{request} has been rejected"
    )
  end

  def withdrawn_notice(request)
    @request = request
    mail(
      :to => request.users.for_perspective(Edition::PERSPECTIVES.first).map(&:to_email),
      :from => request.contact_to_email,
      :subject => "#{request} has been withdrawn"
    )
  end

end

