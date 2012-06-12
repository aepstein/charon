class CreateFrameworksMemberships < ActiveRecord::Migration
  def up
    create_table :frameworks_memberships, id: false do |t|
      t.column :framework_id, :integer, null: false
      t.column :membership_id, :integer, null: false
    end
    add_index :frameworks_memberships, [ :framework_id, :membership_id ],
      unique: true
    say 'Converting existing fulfillments in to framework fulfillments for memberships... (this may take a while)'
    execute <<-SQL
      INSERT INTO frameworks_memberships ( framework_id, membership_id )
      SELECT frameworks.id, memberships.id FROM frameworks, memberships
      WHERE memberships.active = 1 AND
      (SELECT COUNT(*) FROM requirements WHERE framework_id = frameworks.id AND
      (requirements.role_id IS NULL OR requirements.role_id = memberships.role_id))
      =
      (SELECT COUNT(*) FROM requirements INNER JOIN fulfillments
      WHERE framework_id = frameworks.id AND requirements.fulfillable_type =
      fulfillments.fulfillable_type AND requirements.fulfillable_id =
      fulfillments.fulfillable_id AND
      (( fulfiller_type = 'User' AND fulfiller_id = memberships.user_id ) OR
      ( fulfiller_type = 'Organization' AND fulfiller_id = memberships.organization_id )) AND
      (requirements.role_id IS NULL OR requirements.role_id = memberships.role_id))
    SQL
  end

  def down
    remove_index :frameworks_memberships, [ :framework_id, :membership_id ],
      unique: true
    drop_table :frameworks_memberships
  end
end

