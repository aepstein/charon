class Item < ActiveRecord::Base
  belongs_to :node
  belongs_to :request
  has_many :versions do
    def next_stage
      pos = 0
      versions = self.select { |version| true }
      versions.each do |v|
        pos = [pos, v.stage.position].max
      end
      pos + 1
    end
  end
  acts_as_tree
end

