class CreateSteps < ActiveRecord::Migration[5.2]
  def change
    create_table :steps do |t|
      t.string :name, null: false, default: ""
      t.text :memo, null: false, default: ""
      t.integer :status, null: false, default: 0
      t.integer :order, null: false, default: ""
      t.string :scheduled_complete_date, null: false, default: ""
      t.string :completed_date, null: false, default: ""
      t.string :canceled_date, null: false, default: ""
      t.integer :completed_tasks_rate, null: false, default: 0

      t.references :lead, foreign_key: true
      
      t.timestamps
    end
  end
end
