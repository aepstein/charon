class FundGrantMailer < ActionMailer::Base

  helper :application

  def release_notice(fund_grant)
    @fund_grant = fund_grant
    mail(
      :to => fund_grant.users.for_perspective(FundEdition::PERSPECTIVES.first).map(&:to_email),
      :from => fund_grant.contact_to_email,
      :subject => "#{fund_grant} released"
    )
  end

end

