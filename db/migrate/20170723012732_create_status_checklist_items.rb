class CreateStatusChecklistItems < ActiveRecord::Migration[5.1]
  def change
    create_table :status_checklist_items do |t|
      t.string :title
      t.text :description
      t.references :status, foreign_key: true

      t.timestamps
    end
  end
end
