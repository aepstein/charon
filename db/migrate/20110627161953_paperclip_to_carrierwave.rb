class PaperclipToCarrierwave < ActiveRecord::Migration
  def self.up
    rename_column :documents, :attached_file_name, :original
    remove_column :documents, :attached_updated_at
    remove_column :documents, :attached_content_type
    remove_column :documents, :attached_file_size
  end

  def self.down
    add_column :documents, :attached_content_type, :string
    add_column :documents, :attached_file_size, :integer
    add_column :documents, :attached_updated_at, :datetime
    rename_column :documents, :original, :attached_file_name
  end
end

