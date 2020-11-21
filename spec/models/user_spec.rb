require 'rails_helper'

RSpec.describe User, type: :model do
  describe "companies#newで管理者登録時" do
    describe "active_superior_in_the_same_companyメソッドのテスト" do
      context "正しい情報かつ他にユーザーが登録されていない場合" do
        it "登録に成功すること" do
          
        end
      end
      context "すでに管理者や他のユーザーが保存されている場合" do
        it "登録失敗すること" do
          
        end
      end
    end
  end
end
