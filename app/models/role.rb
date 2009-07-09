class Role < ActiveRecord::Base
  has_many :memberships

  def self.officer_roles
    @@officer_roles ||= %w( president vice-president treasurer advisor officer ).map { |n|
      Role.find_or_create_by_name(n)
    }
  end

  def self.finance_officer_roles
    @@finance_officer_roles ||= %w( president treasurer advisor ).map { |n|
      Role.find_or_create_by_name(n)
    }
  end
end

