module AuditableController
  extend ActiveSupport::Concern

  included do
    # record the audit log before every action
    before_action :initialize_audit_log, only: [:create, :update, :destroy]
    # save the audit log
    after_action :save_audit_log, only: [:create, :update, :destroy]
    # set the required specific audit information and auditable object
    after_action :set_audit_log_data, only: [:create, :update, :destroy]
    before_action :set_previous_audit_log_data, only: [:update]
  end

  # creates a audit log record instance that each method model will use
  def initialize_audit_log
    # only save logs for POST,PUT,PATCH and DELETE methods
    # creates
    if (request.post? || request.patch? || request.put? || request.delete? )
      @audit_log = AuditLog.new
      @audit_log.ip = request.remote_ip
      @audit_log.user_name = current_user.first_name || current_user.email
      @audit_log.where = request.headers['latlong'] || "not determined location"
      @audit_log.user_agent = request.user_agent
    end

  end

  # saves the initialzied audit log
  def save_audit_log
    if (@audit_log && @audit_log.auditable)
      changes = objects_diff
      @audit_log.details = "#{action_name} on #{controller_path.titleize}, changes: #{changes}"
      @audit_log.save
    end
  end

  private
    def objects_diff
      attributes_to_ignore = ["id", "updated_at", "created_at"]
      if @audit_log.auditable && @previous_object
        diff = @audit_log.auditable.attributes.collect do |attr|
          if @previous_object[attr[0]] != @audit_log.auditable[attr[0]]
            [attr[0], "#{@previous_object[attr[0]]} => #{@audit_log.auditable[attr[0]]} "]
          end
        end
        diff = diff.compact.delete_if { |attr| attributes_to_ignore.include?(attr[0]) }
        return diff.to_s
      end
      ""
    end

end
