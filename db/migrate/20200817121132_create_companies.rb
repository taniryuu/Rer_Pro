class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.string :name
      t.boolean :admin, default: false
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
