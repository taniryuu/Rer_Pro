require 'rails_helper'

RSpec.describe User, type: :model do
  describe "companies#newで管理者登録時" do
    describe "active_superior_in_the_same_companyメソッドのテスト" do
      before do
        @company = FactoryBot.create(:company)
        @admin = FactoryBot.create(:user, :admin, company_id: @company.id)
      end
      context "正しい情報かつ他にユーザーが登録されていない場合" do
        it "登録に成功すること" do
          expect(@admin).to be_valid
        end
      end
      before do
        @another_company = FactoryBot.create(:company, :another)
        @admin = FactoryBot.create(:user, :admin, company_id: @another_company.id)
      end
      context "すでに管理者や他のユーザーが保存されている場合" do
        it "登録失敗すること" do
          
        end
      end
    end
  end
end
