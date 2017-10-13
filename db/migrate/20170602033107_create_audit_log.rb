class CreateAuditLog < ActiveRecord::Migration[5.1]
  def change
    create_table :audit_logs do |t|
      t.string :user_name
      t.string :where
      t.string :ip
      t.string :user_agent
      t.text :details
      #t.integer :auditable_id
      #t.string :auditable_type
      t.references :auditable, polymorphic: true, index: true

      t.timestamps
    end

    #add_index :audit_logs, [:auditable_type, :auditable_id]
  end
end
