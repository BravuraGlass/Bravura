class Job < ApplicationRecord
  include AuditableModel

  has_many :comments, dependent: :destroy
  has_one :fabrication_order, dependent: :destroy
  has_many :pictures

  belongs_to :customer
  belongs_to :salesman, foreign_key: 'salesman_id', class_name: 'Employee', optional: true
  belongs_to :installer, foreign_key: 'installer_id', class_name: 'Employee', optional: true


  def balance
    price - deposit if price && deposit
  end
end
