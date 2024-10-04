require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'POST #omniauth' do
    context 'when user exists' do
      let(:user) { create(:user, email: 'test@example.com', name: "Hero", uin: "123456789") }

      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
          provider: 'google_oauth2',
          uid: '123456',
          info: {
            email: user.email,
            name: user.name
          }
        })
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]
      end

      it 'logs in the user successfully' do
        post :omniauth, params: { provider: 'google_oauth2' }
        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(user_path(user))
        expect(flash[:notice]).to eq('You are logged in.')
      end
    end
  end

  describe 'GET #logout' do
    let(:user) { create(:user) }

    before do
      session[:user_id] = user.id
    end

    it 'logs out the user successfully' do
      get :logout
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(welcome_path)
      expect(flash[:notice]).to eq('You are logged out.')
    end
  end
end
