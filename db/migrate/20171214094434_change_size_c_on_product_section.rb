class ChangeSizeCOnProductSection < ActiveRecord::Migration[5.1]
  def change
    rename_column :product_sections, :size_c, :fraction_size_a
    rename_column :product_sections, :size_d, :fraction_size_b
  end
end
