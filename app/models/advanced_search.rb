class AdvancedSearch
  include ActiveModel::Model
  include SearchParameter

  PARAMETERS = [
    :date,
    :category,
    :user,
    :address
  ]
  
  attr_accessor *PARAMETERS

  def initialize_params
    PARAMETERS
  end

  def audit_logs(params, page, per_page)
    determine_audit_params(params)
    Rails.logger.info "SQL:::: #{AuditLog.where(@conditions).to_sql} :::::"
    AuditLog.where(@conditions).where(@plain_condition)
  end

  def determine_audit_params(params)
    initialize_conditions
    date_filter(params)
    category_filter(params)
    user_filter(params)
    address_filter(params)
  end

  def initialize_conditions
    @conditions = {}
    @plain_condition = ""
  end

end