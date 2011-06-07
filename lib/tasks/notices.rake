task :notices => [ 'notices:no_prior' ]

namespace :notices do

  desc 'Send notices for requests for which to previous notice has been sent'
  task :no_prior => [ :environment ] do
    notices_log('start "no_prior" task')
    Request.notifiable_events.each { |status| Request.notify_unnotified! status }
    notices_log('complete "no_prior" task')
  end

  def notices_log(message)
    ::Rails.logger.info "rake at #{Time.zone.now}: notices: #{message}"
    ::Rails.logger.flush
  end

end

