class CreateFrameworksMemberships < ActiveRecord::Migration
  class Framework < ActiveRecord::Base
  end

  def up
#    create_table :frameworks_memberships, id: false do |t|
#      t.column :framework_id, :integer, null: false
#      t.column :membership_id, :integer, null: false
#    end
#    add_index :frameworks_memberships, [ :framework_id, :membership_id ],
#      unique: true
    Framework.each do |framework|
      say 'Converting existing fulfillments in to framework fulfillments for memberships...'
      execute <<-SQL
        INSERT INTO frameworks_memberships ( framework_id, membership_id )
        SELECT #{framework.id}, memberships.id FROM memberships
        LEFT JOIN requirements ON requirements.framework_id = #{framework.id} AND
        ( requirements.role_id IS NULL OR requirements.role_id = memberships.role_id )
        LEFT JOIN fulfillments ON fulfillments.fulfillable_type = requirements.fulfillable_type AND
        fulfillments.fulfillable_id = requirements.fulfillable_id AND
        ( ( fulfiller_type = 'User' AND fulfiller_id = memberships.user_id ) OR
            ( fulfiller_type = 'Organization' AND fulfiller_id = memberships.organization_id ) )
        WHERE memberships.active = 1 AND ( requirements.id IS NULL OR
          fulfillments.id IS NOT NULL )
        GROUP BY memberships.id
        ORDER BY fulfillments.id ASC
      SQL
    end
  end

  def down
    remove_index :frameworks_memberships, [ :framework_id, :membership_id ],
      unique: true
    drop_table :frameworks_memberships
  end
end

