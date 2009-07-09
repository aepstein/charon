class Item < ActiveRecord::Base
  belongs_to :node
  belongs_to :request
  has_many :versions, :autosave => true do
    def next_stage
      pos = 0
      self.select{ |version| not version.new_record? }.each do |v|
        pos = [pos, v.stage.position].max
      end
      pos + 1
    end
    def prev_version(stage_pos)
      self.select { |version| version.stage.position == stage_pos - 1 }[0]
    end
    def last_version
      self.select { |version| version.stage.position == self.versions.next_stage - 1 }
    end
  end
  acts_as_tree

end

