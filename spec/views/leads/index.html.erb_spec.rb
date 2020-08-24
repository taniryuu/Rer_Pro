require 'rails_helper'

RSpec.describe "leads/index", type: :view do
  before(:each) do
    assign(:leads, [
      Lead.create!(
        user_id: 2,
        customer_name: "Customer Name",
        room_name: "Room Name",
        room_num: "Room Num",
        template: false,
        template_name: "Template Name",
        memo: "Memo",
        status: 3,
        notice_created: false,
        notice_change_limit: false,
        steps_rate: 4
      ),
      Lead.create!(
        user_id: 2,
        customer_name: "Customer Name",
        room_name: "Room Name",
        room_num: "Room Num",
        template: false,
        template_name: "Template Name",
        memo: "Memo",
        status: 3,
        notice_created: false,
        notice_change_limit: false,
        steps_rate: 4
      )
    ])
  end

  it "renders a list of leads" do
    render
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: "Customer Name".to_s, count: 2
    assert_select "tr>td", text: "Room Name".to_s, count: 2
    assert_select "tr>td", text: "Room Num".to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: "Template Name".to_s, count: 2
    assert_select "tr>td", text: "Memo".to_s, count: 2
    assert_select "tr>td", text: 3.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: 4.to_s, count: 2
  end
end
