RSpec.describe WelcomeController, type: :controller do
    describe "GET #index" do
      context "when user is logged in" do
        let(:user) { create(:user) }

        before do
          allow(controller).to receive(:logged_in?).and_return(true)
          allow(controller).to receive(:current_user).and_return(user)
        end

        it "redirects to the user's page" do
          get :index
          expect(response).to redirect_to(user_path(user))
        end

        it "sets a welcome back notice" do
          get :index
          expect(flash[:notice]).to eq("Welcome, back!")
        end
      end
    end
  end
