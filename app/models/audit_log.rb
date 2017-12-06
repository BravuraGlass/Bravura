class AuditLog < ApplicationRecord
  # all auditable models can have audit logs
  belongs_to :auditable, polymorphic: true
end
