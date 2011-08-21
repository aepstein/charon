module Notifiable
  module InstanceMethods
  end

  module ClassMethods

    # Defines events for which notices may be sent
    # Generates the following class methods for each event:
    # no_event_notice: All records for which no notice has been sent
    # no_event_notice_since( time ): All records for which no notice sent
    #  or no notice sent since specified time
    # Generates the following instance methods:
    # send_event_notice!: Sends notice regarding event and records timestamp
    # Allowed options:
    # * :if => symbol or array of symmbols of instance methods to call before
    #   sending notice -- will not send notice if any of these returns false
    # * :unless => symbol or array of symbols of instance methods to call before
    #   sending notice -- will not send if any of these does not return (nil|false)
    def notifiable_events( *events )
      @notifiable_events ||= Array.new
      options = events.extract_options!
      return @notifiable_events if events.empty?
      ifs = [ options.delete( :if ) || [] ].flatten
      unlesses = [ options.delete( :unless ) || [] ].flatten
      new_events = events - notifiable_events
      new_events.flatten.each do |event|
        scope "no_#{event}_notice".to_sym, where( "#{event}_notice_at".to_sym => nil )
        scope "no_#{event}_notice_since".to_sym, lambda { |time|
          t = arel_table
          f = arel_table["#{event}_notice_at".to_sym]
          where( f.eq( nil ).or( f.lt( time ) ) )
        }
        define_method "send_#{event}_notice!".to_sym do
          ifs.each { |condition| return false unless send(condition) }
          unlesses.each { |condition| return false if send(condition) }
          message = "#{self.class}Mailer".constantize.send( "#{event}_notice", self ).deliver
          logger.info "[charon] Sent #{event} notice for #{self.class}##{id} to: " +
            "#{message.to}, cc: #{message.cc}, bcc: #{message.bcc}."
          send "#{event}_notice_at=", Time.zone.now
          save! :validate => false
        end
      end
      @notifiable_events += new_events
    end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

