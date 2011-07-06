class ApprovalMailer < ActionMailer::Base
  helper :application

  def approval_notice(approval)
    @approval = approval
    mail(
      :to => approval.user.email,
      :from => "#{approval.approvable.contact_name} <#{approval.approvable.contact_email}>",
      :subject => "Confirmation of your approval for #{approval.approvable}"
    )
  end

  def unapproval_notice(approval)
    @approval = approval
    mail(
      :to => approval.user.email,
      :from => "#{approval.approvable.contact_name} <#{approval.approvable.contact_email}>",
      :subject => "Your approval for #{approval.approvable} has been removed"
    )
  end

  def fund_request_notice(approval)
    @approval = approval
    mail(
      :to => approval.user.email,
      :from => "#{approval.approvable.contact_name} <#{approval.approvable.contact_email}>",
      :subject => "Your approval required for #{approval.approvable}"
    )
  end

end

