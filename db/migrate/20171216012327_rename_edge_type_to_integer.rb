class RenameEdgeTypeToInteger < ActiveRecord::Migration[5.1]
  def up
    ["a","b"].each do |str|
      remove_column :product_sections, "size_#{str}"
      add_column :product_sections, "size_#{str}", :integer
    end
    ["a","b","c","d"].each do |str|
      remove_column :product_sections, "edge_type_#{str}"
      add_column :product_sections, "edge_type_#{str}_id", :bigint
      add_foreign_key :product_sections, :edge_types, column: "edge_type_#{str}_id"
    end
  end

  def down
    ["a","b"].each do |str|
      change_column :product_sections, "size_#{str}", :string
    end
    ["a","b","c","d"].each do |str|
      remove_foreign_key :product_sections, column: "edge_type_#{str}_id"
      rename_column :product_sections, "edge_type_#{str}_id", "edge_type_#{str}"
      change_column :product_sections, "edge_type_#{str}", :string
    end
  end
end
