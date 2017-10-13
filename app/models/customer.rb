class Customer < ApplicationRecord
  include AuditableModel

  has_many :jobs, dependent: :destroy
  validates_presence_of :contact_firstname, :on => :create
  validates_presence_of :contact_lastname, :on => :create



  def contact_info
    "#{contact_firstname} #{contact_lastname} - #{company_name}"
  end

  def contact_details
    "#{email} #{address} #{phone_number} #{fax}"
  end
end
