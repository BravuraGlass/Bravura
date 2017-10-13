class Employee < ApplicationRecord
  include AuditableModel

  has_many :installer_jobs, foreign_key: 'installer_id', class_name: 'Job'
  has_many :salesman_jobs, foreign_key: 'installer_id', class_name: 'Job'
end
