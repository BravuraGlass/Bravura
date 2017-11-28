class AddBalanceToJob < ActiveRecord::Migration[5.1]
  def change
    add_column :jobs, :balance, :decimal
  end
end
