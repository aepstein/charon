class OrganizationMailer < ActionMailer::Base
  default from: "#{Charon::Application.app_config['default_contact']['name']} <#{Charon::Application.app_config['default_contact']['email']}>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.organization.unregistered_notice.subject
  #
  def unregistered_notice( organization )
    @organization = organization

    mail to: "to@example.org"
  end
end

