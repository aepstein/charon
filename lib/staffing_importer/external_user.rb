module StaffingImporter
  class ExternalUser < ActiveRecord::Base

    MAP = {
      # old column names => new column names
      :id                => :external_id,
      :first_name        => :first_name,
      :last_name         => :last_name,
      :email             => :email,
      :net_id            => :net_id
    }
    USER_ATTRIBUTES = [ :net_id, :first_name, :last_name, :email ]

    establish_connection "external_staffing_#{::Rails.env}".to_sym
    set_table_name "users"
    set_primary_key :id

    scope :with_source, lambda { |source|
      { :joins => 'INNER JOIN memberships ON users.id = memberships.user_id INNER JOIN ' +
          'enrollments ON memberships.position_id = enrollments.position_id',
        :conditions => [ 'memberships.starts_at <= :t AND memberships.ends_at >= :t ' +
          'AND enrollments.committee_id = :i AND enrollments.votes >= :v',
          { :t => Time.zone.now, :i => source.external_committee_id, :v => source.minimum_votes } ] }
    }

    # Returns array of information about records affected by update
    def self.import( source )
      adds, changes, deletes, starts = 0, 0, 0, Time.zone.now
      users = ExternalUser.with_source( source ).all
      # Add new memberships
      users.each do |external|
        user = User.find_or_initialize_by_net_id( external.net_id )
        USER_ATTRIBUTES.each do |attribute|
          user.send "#{MAP[attribute]}=", external.send( attribute )
        end
        user.save && changes += 1 if user.changed?
        unless source.users.include?( user )
          adds += 1
          source.memberships.create( :user => user, :active => true )
        end
      end
      # Remove old memberships
      old = source.users.map(&:net_id) - users.map(&:net_id)
      unless old.empty?
        source.memberships.delete( source.memberships.unscoped.joins(:user) & User.unscoped.where(:net_id.in => old) )
      end
      [adds, changes, old.length, ( Time.zone.now - starts )]
    end

  end

end

