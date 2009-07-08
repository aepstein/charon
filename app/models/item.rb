class Item < ActiveRecord::Base
  belongs_to :node
  belongs_to :request
  has_many :versions, :autosave => true do
    def next_stage
      pos = 0
      versions = self.select { |version| true }
      versions.each do |v|
        pos = [pos, v.stage.position].max
      end
      pos + 1
    end
    def last_version
      self.select { |version| version.stage.position == self.versions.next_stage - 1 }
    end
  end
  acts_as_tree
  validates_associated :versions, :message => "invalid amount"

end

