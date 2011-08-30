class PopulateUserPasswords < ActiveRecord::Migration
  class User < ActiveRecord::Base
    has_secure_password

    def initialize_password
      if password.blank?
        chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
        newpass = ""
        1.upto(8) { |i| newpass << chars[rand(chars.size-1)] }
        self.password, self.password_confirmation = newpass, newpass
      end
      true
    end
  end

  def up
    say 'Setting random password for users who do not have a password'
    User.where( :password_digest => nil ).each do |user|
      user.initialize_password
      user.save!
    end
  end

  def down
  end
end

