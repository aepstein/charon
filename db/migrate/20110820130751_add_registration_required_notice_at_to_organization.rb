class AddRegistrationRequiredNoticeAtToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :registration_required_notice_at, :datetime
  end
end

