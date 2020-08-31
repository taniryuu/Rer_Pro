class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.references :step, foreign_key: true
      t.string :name, null: false, default: ""
      t.text :memo, null: false, default: ""
      t.integer :status, null: false, default: 0
      t.string :scheduled_complete_date, null: false, default: ""
      t.string :completed_date, null: false, default: ""
      t.string :canceled_date, null: false, default: ""

      t.timestamps
    end
  end
end
