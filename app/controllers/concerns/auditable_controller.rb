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
      @audit_log.user_name = current_user.full_name
    end

  end

  # saves the initialzied audit log
  def save_audit_log
    if (@audit_log && @audit_log.auditable)
      if ["update","destroy"].include?(action_name)
        update_and_destroy_audit
      elsif action_name == "create"
        create_audit
      end 
    end
  end

  def create_audit
    object = @audit_log.auditable_type
    if object == "Product"
      @audit_log.details = "Newly created data"
      @audit_log.save

    end
  end

  def update_and_destroy_audit
    changes = objects_diff
    unless changes == [] || changes == ""
      object = @audit_log.auditable_type
      object = "Material" if object == "ProductSection"
      object = "Task" if object == "Product"

      details = []
      changes.each do |change|
        details << "updated #{object.downcase}'s #{change[0]} from #{change[1]} to #{change[2]}"
      end

      @audit_log.details = details.join(". ")
      @audit_log.save
    end
  end

  private
    def objects_diff
      if @audit_log.auditable && @previous_object
        diff = @audit_log.auditable.attributes.collect do |attr|
          if @previous_object[attr[0]] != @audit_log.auditable[attr[0]]
            [attr[0], @previous_object[attr[0]], @audit_log.auditable[attr[0]]]
          end
        end
        diff = diff.compact.delete_if { |attr| auditable_attributes_to_ignore.include?(attr[0]) }
        return diff
      end
      ""
    end

    def auditable_attributes_to_ignore
      ["id", "updated_at", "created_at"]
    end

end
