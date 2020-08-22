class CreateLeads < ActiveRecord::Migration[5.2]
  def change
    create_table :leads do |t|
      t.datetime :created_date, null: false, default: CURRENT_TIMESTAMP
      t.date :completed_date, null: false, default: "9999-12-31"
      t.string :customer_name, null: false, default: ""
      t.string :room_name, null: false, default: ""
      t.string :room_num, null: false, default: ""
      t.boolean :template, null: false, default: false
      t.string :template_name, null: false, default: ""
      t.string :memo, null: false, default: ""
      t.integer :status, null: false, default: 0
      t.boolean :notice_created, null: false, default: false
      t.boolean :notice_change_limit, null: false, default: false
      t.date :scheduled_resident_date, null: false, default: "9999-12-31"
      t.date :scheduled_payment_date, null: false, default: "9999-12-31"
      t.date :scheduled_contract_date, null: false, default: "9999-12-31"
      t.integer :steps_rate, null: false, default: 0
      
      t.references :user, foreign_key: true
      
      t.timestamps null: false
    end
  end
end
