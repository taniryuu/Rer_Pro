require 'rails_helper'

RSpec.describe "leads/show", type: :view do
  before(:each) do
    @lead = assign(:lead, Lead.create!(
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
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Customer Name/)
    expect(rendered).to match(/Room Name/)
    expect(rendered).to match(/Room Num/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Template Name/)
    expect(rendered).to match(/Memo/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/4/)
  end
end
