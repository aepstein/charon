class ConvertToKualiUniversityAccounts < ActiveRecord::Migration
  class Registration < ActiveRecord::Base
    has_one :organization, :foreign_key => :last_current_registration_id
  end

  class Organization < ActiveRecord::Base
    belongs_to :last_current_registration, :class_name => 'Registration'
    has_many :university_accounts, :inverse_of => :organization
    scope :registered, joins( "INNER JOIN registrations ON " +
      "organizations.last_current_registration_id = registrations.id" )
    scope :unregistered, where( "last_current_registration_id IS NULL" )
  end

  class UniversityAccount < ActiveRecord::Base
    belongs_to :organization, :inverse_of => :university_accounts
    default_scope joins( "INNER JOIN organizations ON " +
      "university_accounts.organization_id = organizations.id" )

    scope :independent, lambda {
      scoped.merge( Organization.registered.merge(
        Registration.where( :independent => true ) ) )
    }
    scope :university, lambda {
      scoped.merge( Organization.registered.merge(
        Registration.where( :independent => false ) ) )
    }
    scope :unregistered, lambda { scoped.merge( Organization.unregistered ) }

    def migrate!( code )
      self.subaccount_code = "#{department_code[2]}#{subledger_code}"
      self.subledger_code = code
      save!
    end
  end

  def up
    add_column :university_accounts, :subaccount_code, :string, :limit => 5
    remove_index :university_accounts, [ :department_code, :subledger_code ]
    add_index :university_accounts, [ :department_code, :subledger_code, :subaccount_code ],
      :unique => true, :name => 'unique_code'
    UniversityAccount.reset_column_information
    say_with_time 'Converting accounts to new numbering conventions' do
      i = UniversityAccount.independent.count
      UniversityAccount.independent.readonly(false).each { |account| account.migrate! "4050" }
      say "#{i} independent accounts migrated"
      i = UniversityAccount.university.count
      UniversityAccount.university.readonly(false).each { |account| account.migrate! "4000" }
      say "#{i} university accounts migrated"
      i = UniversityAccount.unregistered.count
      UniversityAccount.unregistered.readonly(false).each { |account| account.migrate! "XXXX" }
      say "#{i} unregistered accounts migrated"
    end
    change_column :university_accounts, :subaccount_code, :string, :limit => 5, :null => false
  end

  def down
    raise IrreversibleMigration
  end
end

