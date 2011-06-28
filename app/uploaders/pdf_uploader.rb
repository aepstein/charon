class PdfUploader < CarrierWave::Uploader::Base

  # Replace filename extension with chosen alternative
  def substitute_extension(filename, extension)
    return nil if filename.blank?
    filename.chomp(File.extname(filename)) + ".#{extension}"
  end

  # Use mounted_as parameter to give file predictable name
  def filename
    return "#{mounted_as}" if super.blank?
    "#{mounted_as}#{File.extname(super)}"
  end

  # Partitions model id in form 000/000/001 for scalable storage
  def partitioned_model_id
    ("%09d" % model.id).scan(/\d{3}/).join("/")
  end

  def store_dir
    "#{::Rails.root}/db/uploads/#{::Rails.env}/#{model.class.arel_table.name}/#{partitioned_model_id}"
  end

  def extension_white_list
    %w( pdf )
  end

end

