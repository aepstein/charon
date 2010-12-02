class Document < ActiveRecord::Base
  default_scope includes( :document_type).order( 'document_types.name ASC' )

  belongs_to :edition
  belongs_to :document_type

  has_attached_file :attached,
    :path => ':rails_root/db/uploads/:rails_env/:id_partition/:attachment/:style.:extension',
    :url => '/documents/:id.:format'

  delegate :max_size, :to => :document_type
  delegate :max_size_string, :to => :document_type

  validates_attachment_presence :attached
  validates_presence_of :edition
  validates_presence_of :document_type
  validates_uniqueness_of :document_type_id, :scope => [ :edition_id ]
  validate :attached_file_size_must_be_less_than_max,
           :document_type_must_be_allowed_by_edition

  def attached_file_size_must_be_less_than_max
    return unless document_type && attached_file_size?
    if attached_file_size > max_size
      errors.add( :attached, "is larger than #{max_size_string}." )
    end
  end

  def document_type_must_be_allowed_by_edition
    return if edition.nil? || document_type.nil?
    unless edition.document_types.include?( document_type )
      errors.add( :document_type, "is not a valid document type for #{edition}." )
    end
  end

end

