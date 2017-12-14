class ModifyMaterialSize < ActiveRecord::Migration[5.1]
  def change
    remove_column :product_sections, :size
    ["a","b","c","d"].each do |str|
      add_column :product_sections, "size_#{str}", :string
    end  
    
    ["a","b","c","d"].each do |str|
      add_column :product_sections, "edge_type_#{str}", :string
    end 
  end
end
