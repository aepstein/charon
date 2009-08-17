class Document < ActiveRecord::Base
  default_scope :include => :document_type, :order => 'document_types.name ASC'

  belongs_to :version
  belongs_to :document_type

  has_attached_file :attached,
    :path => ':rails_root/db/uploads/:rails_env/:id_partition/:attachment/:style.:extension',
    :url => '/documents/:id.:format'

  delegate :max_size, :to => :document_type
  delegate :max_size_string, :to => :document_type
  delegate :may_update?, :to => :version
  delegate :may_see?, :to => :version
  delegate :may_destroy?, :to => :version

  validates_attachment_presence :attached
#  validates_presence_of :version
  validates_presence_of :document_type
  validates_uniqueness_of :document_type_id, :scope => [ :version_id ]
  validate :attached_file_size_must_be_less_than_max,
           :document_type_must_be_allowed_by_version

  def attached_file_size_must_be_less_than_max
    return unless document_type && attached_file_size?
    if attached_file_size > max_size
      errors.add( :attached, "is larger than #{max_size_string}." )
    end
  end

  def document_type_must_be_allowed_by_version
    return if version.nil? || document_type.nil?
    unless version.document_types.include?( document_type )
      errors.add( :document_type, "is not a valid document type for #{version}." )
    end
  end

  def may_create?(user)
    may_update? user
  end
end

