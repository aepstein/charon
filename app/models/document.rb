class Document < ActiveRecord::Base
  attr_accessible :document_type_id, :original, :original_cache
  attr_readonly :document_type_id

  default_scope includes( :document_type).order( 'document_types.name ASC' )

  belongs_to :edition, :inverse_of => :documents
  belongs_to :document_type, :inverse_of => :documents

  mount_uploader :original, PdfUploader

  validates :original, :presence => true, :integrity => true,
    :file_size => { :maximum => :max_size }
  validates :edition, :presence => true
  validates :document_type, :presence => true
  validates :document_type_id, :uniqueness => { :scope => [ :edition_id ] }
  validate :document_type_must_be_allowed_by_edition

  def max_size; return document_type.max_size if document_type; end

  def max_size_string; return document_type.max_size_string if document_type; end

  private

  def document_type_must_be_allowed_by_edition
    return if edition.blank? || document_type.blank?
    unless edition.document_types.include?( document_type )
      errors.add( :document_type, "is not a valid document type for #{edition}" )
    end
  end

end

