require 'rails_helper'

RSpec.describe "Companies", type: :controller do
  describe 'GET #index' do
    context 'getアクションが呼び出された時' do
      it 'レスポンスコードが200であること' do
        
      end

      it 'indexテンプレートをレンダリングすること' do
        
      end
    end
  end

  describe 'POST #create' do
    context '正しい情報が渡ってきた時' do
      it 'データが一つ増えていること' do
        
      end

      it '指定のページにリダイレクトされていること' do
        
      end
    end

    context '誤った情報が渡ってきた時' do
      it '登録画面に戻されること' do
        
      end
    end
  end

  describe 'GET #new' do
    context 'getアクションが呼び出された時' do
      
    end
  end

  describe 'GET #edit' do
    context 'getアクションが呼び出された時' do
    end
  end

  describe 'GET #show' do
    context 'getアクションが呼び出された時' do
    end
  end

  describe 'PATCH #update' do
    context '正しい情報が渡ってきた時' do
      it '指定のページにリダイレクトされていること' do
        
      end
    end

    context '誤った情報が渡ってきた時' do
      it '指定のページにリダイレクトされていること' do
        
      end
    end
  end

  describe 'DELETE #destroy' do
    context '削除に成功した時' do
      it 'データが一つ減っていること' do
        
      end

      it '指定のページにリダイレクトされていること' do
        
      end
    end

    context '削除に失敗した時' do
      it '指定のページにリダイレクトされていること' do
        
      end
    end
  end
end
