class ConvertRegistrationWhenUpdatedToInteger < ActiveRecord::Migration
  def self.up
    case connection.adapter_name.downcase
    when /^mysql/
      sql = "UPDATE registrations SET when_updated = UNIX_TIMESTAMP(when_updated_legacy)"
    when /^sqlite/
      sql = "UPDATE registrations SET when_updated = STRFTIME('%s',when_updated_legacy)"
    else
      raise "#{connection.adapter_name.downcase} adapter not supported"
    end
    add_column :registrations, :when_updated_legacy, :datetime
    connection.send(:update_sql, "UPDATE registrations SET when_updated_legacy = when_updated")
    change_column :registrations, :when_updated, :integer
    connection.send(:update_sql, sql)
  end

  def self.down
    change_column :registrations, :when_updated, :datetime
    connection.send(:update_sql, "UPDATE registrations SET when_updated = when_updated_legacy")
    remove_column :registrations, :when_updated_legacy
  end
end

