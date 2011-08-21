class OrganizationMailer < ActionMailer::Base
  default from: "#{Charon::Application.app_config['default_contact']['name']} <#{Charon::Application.app_config['default_contact']['email']}>"

  def registration_required_notice( organization )
    @organization = organization

    mail to: organization.last_current_users.map(&:to_email),
      subject: "Current registration required for #{organization}"
  end
end

