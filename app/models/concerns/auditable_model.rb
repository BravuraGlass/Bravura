module AuditableModel
  extend ActiveSupport::Concern

  included do
    has_many :audit_logs, as: :auditable
  end
end
