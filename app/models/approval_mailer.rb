class ApprovalMailer < ActionMailer::Base

  def approval_notice(approval)
    recipients approval.user.email
    from       "#{approval.approvable.contact_name} <#{approval.approvable.contact_email}>"
    subject    "Confirmation of your approval for #{approval.approvable}"
    sent_on    Time.now
    body       :approval => approval
  end

  def unapproval_notice(approval)
    recipients approval.user.email
    from       "#{approval.approvable.contact_name} <#{approval.approvable.contact_email}>"
    subject    "Your approval for #{approval.approvable} has been removed"
    sent_on    Time.now
    body       :approval => approval
  end

  def request_notice(approval)
    recipients  approval.user.email
    from        "#{approval.approvable.contact_name} <#{approval.approvable.contact_email}>"
    subject     "Your approval required for #{approval.approvable}"
    sent_on     Time.now
    body        :approval => approval
  end

end

