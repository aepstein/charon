class Document < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true
  belongs_to :document_type
  has_attached_file :attached

  delegate :max_size, :to => :document_type
  delegate :max_size_string, :to => :document_type

  validates_presence_of :attachable
  validates_presence_of :document_type
  validates_uniqueness_of :document_type_id, [ :attachable_id, :attachable_type ]
  validate :attached_file_size_must_be_less_than_max,
    :document_type_must_be_allowed_by_attachable

  def attached_file_size_must_be_less_than_max
    return unless document_type && attached_file_size?
    if attached_file_size > max_size
      errors.add( :attached, "is larger than #{max_size_string}." )
    end
  end

  def document_type_must_be_allowed_by_attachable
    return if attachable.nil? || document_type.nil?
    unless attachable.document_types.include?( document_type )
      errors.add( :document_type, "is not a valid document type for #{attachable}." )
    end
  end

  delegate :may_update?, :to => :attachable
  delegate :may_see?, :to => :attachable
  delegate :may_destroy?, :to => :attachable

  def may_create?(user)
    may_update? user
  end
end

