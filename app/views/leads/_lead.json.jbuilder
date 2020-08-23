json.extract! lead, :id, :created_date, :completed_date, :customer_name, :room_name, :room_num, :template, :template_name, :memo, :status, :notice_created, :notice_change_limit, :scheduled_resident_date, :scheduled_payment_date, :scheduled_contract_date, :steps_rate, :created_at, :updated_at
json.url lead_url(lead, format: :json)
