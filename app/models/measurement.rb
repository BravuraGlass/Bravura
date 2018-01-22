class Measurement < Asset
  mount_base64_uploader :data, MeasurementUploader
  belongs_to :owner, class_name: 'Job'
  validates_integrity_of :data
  validates_processing_of :data

  def job_id
    self.owner_id if self.owner_type == "Job"
  end
end
