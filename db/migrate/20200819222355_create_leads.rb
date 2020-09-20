class CreateLeads < ActiveRecord::Migration[5.2]
  def change
    create_table :leads do |t|
      t.string :created_date, null: false, default: ""
      t.string :completed_date, null: false, default: ""
      t.string :canceled_date, null: false, default: ""
      t.string :customer_name, null: false, default: ""
      t.string :room_name, null: false, default: ""
      t.string :room_num, null: false, default: ""
      t.boolean :template, null: false, default: false
      t.string :template_name, null: false, default: ""
      t.string :memo, null: false, default: ""
      t.integer :status, null: false, default: 0
      t.boolean :notice_created, null: false, default: true
      t.boolean :notice_change_limit, null: false, default: false
      t.string :scheduled_resident_date, null: false, default: ""
      t.string :scheduled_payment_date, null: false, default: ""
      t.string :scheduled_contract_date, null: false, default: ""
      t.integer :steps_rate, null: false, default: 0
      
      # Userモデルと紐づけ
      t.references :user, foreign_key: true
      
      t.timestamps null: false
    end
  end
end
