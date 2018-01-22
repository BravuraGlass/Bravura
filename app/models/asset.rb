class Asset < ApplicationRecord
  belongs_to :user
  before_save :check_extension

  def check_extension
    if self.data
      self.data_file_name = self.data.filename
      self.data_content_type = self.data.file.try(:content_type)
      self.data_file_size = self.data.file.try(:size)
      self.order = self.next_order
      self.data_updated_at = Time.now
    end
  end

  def next_order
    Asset.find_by(owner_id: self.owner_id, owner_type: self.owner_type).id.next rescue 1
  end

  def image?
    self.data_content_type.start_with?('image') rescue false
  end
  
end
