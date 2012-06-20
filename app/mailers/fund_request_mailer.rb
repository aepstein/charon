class FundRequestMailer < ActionMailer::Base

  helper :application

  def started_notice(fund_request)
    @fund_request = fund_request
    mail(
      to: fund_request.requestors.requestor.map(&:to_email),
      from: fund_request.contact_to_email,
      subject: "#{fund_request} needs attention"
    )
  end

  def tentative_notice(fund_request)
    @fund_request = fund_request
    mail(
      to: fund_request.users.unfulfilled( Approver.where( :quantity => nil ) ).map(&:to_email),
      from: fund_request.contact_to_email,
      subject: "#{fund_request} needs your approval"
    )
  end

  def finalized_notice( fund_request )
    @fund_request = fund_request
    mail(
      to: fund_request.requestors.requestor.map(&:to_email),
      from: fund_request.contact_to_email,
      subject: "#{fund_request} is finalized, but not submitted"
    )
  end

  def submitted_notice( fund_request )
    @fund_request = fund_request
    message = mail(
      to: fund_request.requestors.requestor.map(&:to_email),
      from: fund_request.contact_to_email,
      subject: "#{fund_request} has been accepted for review"
    )
    if fund_request.fund_items.documentable.any?
      filename = "#{fund_request.fund_grant.organization.to_s :file}-checklist.pdf"
      message.attachments[filename] = DocumentsReport.new( fund_request ).to_pdf
    end
    message
  end

  def released_notice(fund_request)
    @fund_request = fund_request
    mail(
      to: fund_request.requestors.requestor.map(&:to_email),
      from: fund_request.contact_to_email,
      subject: "Preliminary determination for #{fund_request}"
    )
  end

  def allocated_notice(fund_request)
    @fund_request = fund_request
    mail(
      to: fund_request.requestors.requestor.map(&:to_email),
      from: fund_request.contact_to_email,
      subject: "Allocation for #{fund_request}"
    )
  end

  def rejected_notice(fund_request)
    @fund_request = fund_request
    mail(
      to: fund_request.requestors.requestor.map(&:to_email),
      from: fund_request.contact_to_email,
      subject: "#{fund_request} has been rejected"
    )
  end

  def withdrawn_notice(fund_request)
    @fund_request = fund_request
    mail(
      to: fund_request.requestors.requestor.map(&:to_email),
      from: fund_request.contact_to_email,
      subject: "#{fund_request} has been withdrawn"
    )
  end

end

