class FundRequestMailer < ActionMailer::Base

  helper :application

  def started_notice(fund_request)
    @fund_request = fund_request
    mail(
      :to => fund_request.fund_grant.users.for_perspective(FundEdition::PERSPECTIVES.first).map(&:to_email),
      :from => fund_request.contact_to_email,
      :subject => "#{fund_request} needs attention"
    )
  end

  def completed_notice(fund_request)
    @fund_request = fund_request
    mail(
      :to => fund_request.users.unfulfilled( Approver.where( :quantity => nil ) ).map(&:to_email),
      :from => fund_request.contact_to_email,
      :subject => "#{fund_request} needs your approval"
    )
  end

  def submitted_notice( fund_request )
    @fund_request = fund_request
    mail(
      :to => fund_request.fund_grant.users.for_perspective(FundEdition::PERSPECTIVES.first).map(&:to_email),
      :from => fund_request.contact_to_email,
      :subject => "#{fund_request} has been submitted"
    )
  end

  def accepted_notice( fund_request )
    @fund_request = fund_request
    mail(
      :to => fund_request.fund_grant.users.for_perspective(FundEdition::PERSPECTIVES.first).map(&:to_email),
      :from => fund_request.contact_to_email,
      :subject => "#{fund_request} has been accepted for review"
    )
  end

  def released_notice(fund_request)
    @fund_request = fund_request
    mail(
      :to => fund_request.fund_grant.users.for_perspective(FundEdition::PERSPECTIVES.first).map(&:to_email),
      :from => fund_request.contact_to_email,
      :subject => "You may now review #{fund_request}"
    )
  end

  def rejected_notice(fund_request)
    @fund_request = fund_request
    mail(
      :to => fund_request.fund_grant.users.for_perspective(FundEdition::PERSPECTIVES.first).map(&:to_email),
      :from => fund_request.contact_to_email,
      :subject => "#{fund_request} has been rejected"
    )
  end

  def withdrawn_notice(fund_request)
    @fund_request = fund_request
    mail(
      :to => fund_request.fund_grant.users.for_perspective(FundEdition::PERSPECTIVES.first).map(&:to_email),
      :from => fund_request.contact_to_email,
      :subject => "#{fund_request} has been withdrawn"
    )
  end

end

