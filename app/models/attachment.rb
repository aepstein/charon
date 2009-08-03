class Attachment < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true
  belongs_to :attachment_type
  has_attached_file :attached

  delegate :max_size, :to => :attachment_type
  delegate :max_size_string, :to => :attachment_type

  validates_presence_of :attachable
  validates_presence_of :attachment_type
  validates_uniqueness_of :attachment_type_id, [ :attachable_id, :attachable_type ]
  validate :attached_file_size_must_be_less_than_max,
    :attachment_type_must_be_allowed_by_attachable

  def attached_file_size_must_be_less_than_max
    return unless attachment_type && attached_file_size?
    if attached_file_size > max_size
      errors.add( :attached, "is larger than #{max_size_string}." )
    end
  end

  def attachment_type_must_be_allowed_by_attachable
    return if attachable.nil? || attachment_type.nil?
    unless attachable.attachment_types.include?( attachment_type )
      errors.add( :attachment_type, "is not a valid attachment type for #{attachable}." )
    end
  end

  delegate :may_update?, :to => :attachable
  delegate :may_see?, :to => :attachable
  delegate :may_destroy?, :to => :attachable

  def may_create?(user)
    may_update? user
  end
end

