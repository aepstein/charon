class CreateAgreementCriterions < ActiveRecord::Migration
  def self.up
    create_table :agreement_criterions do |t|
      t.references :agreement

      t.timestamps
    end
  end

  def self.down
    drop_table :agreement_criterions
  end
end
