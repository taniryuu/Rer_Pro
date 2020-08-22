require 'rails_helper'

RSpec.describe "leads/edit", type: :view do
  before(:each) do
    @lead = assign(:lead, Lead.create!(
      user_id: 1,
      customer_name: "MyString",
      room_name: "MyString",
      room_num: "MyString",
      template: false,
      template_name: "MyString",
      memo: "MyString",
      status: 1,
      notice_created: false,
      notice_change_limit: false,
      steps_rate: 1
    ))
  end

  it "renders the edit lead form" do
    render

    assert_select "form[action=?][method=?]", lead_path(@lead), "post" do

      assert_select "input[name=?]", "lead[user_id]"

      assert_select "input[name=?]", "lead[customer_name]"

      assert_select "input[name=?]", "lead[room_name]"

      assert_select "input[name=?]", "lead[room_num]"

      assert_select "input[name=?]", "lead[template]"

      assert_select "input[name=?]", "lead[template_name]"

      assert_select "input[name=?]", "lead[memo]"

      assert_select "input[name=?]", "lead[status]"

      assert_select "input[name=?]", "lead[notice_created]"

      assert_select "input[name=?]", "lead[notice_change_limit]"

      assert_select "input[name=?]", "lead[steps_rate]"
    end
  end
end
