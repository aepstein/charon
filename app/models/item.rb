class Item < ActiveRecord::Base
  belongs_to :node
  belongs_to :request
  has_many :versions, :autosave => true do
    def next_stage
      saved_versions = self.select { |version| not version.new_record? }
      return saved_versions.map { |v| v.stage_id }.max + 1 if saved_versions.size > 0
      0
    end

    def prev_version(stage_pos)
      self.select { |version| version.stage_id == stage_pos - 1 }[0]
    end

    def last_version
      self.select { |version| version.stage_id == self.versions.next_stage - 1 }[0]
    end
  end
  acts_as_tree

  def may_create?(user)
    request.may_update?(user)
  end

  def may_update?(user)
    request.may_update?(user)
  end

  def may_destroy?(user)
    request.may_update?(user)
  end

  def may_see?(user)
    request.may_see?(user)
  end

end

