class Document < ActiveRecord::Base
  attr_accessible :document_type_id, :original, :original_cache
  attr_readonly :document_type_id

  belongs_to :fund_edition, :inverse_of => :documents
  belongs_to :document_type, :inverse_of => :documents

  mount_uploader :original, PdfUploader

  has_paper_trail :class_name => 'SecureVersion'

  validates :original, :presence => true, :integrity => true,
    :file_size => { :maximum => :max_size }
  validates :fund_edition, :presence => true
  validates :document_type, :presence => true
  validates :document_type_id, :uniqueness => { :scope => [ :fund_edition_id ] }
  validate :document_type_must_be_allowed_by_fund_edition

  default_scope includes( :document_type).order( 'document_types.name ASC' )

  def max_size; return document_type.max_size if document_type; end

  def max_size_string; return document_type.max_size_string if document_type; end

  private

  def document_type_must_be_allowed_by_fund_edition
    return if fund_edition.blank? || fund_edition.fund_item.blank? ||
      fund_edition.fund_item.node.blank? || document_type.blank?
    unless fund_edition.fund_item.node.document_types.include?( document_type )
      errors.add( :document_type, "is not a valid document type for #{fund_edition}" )
    end
  end

end

