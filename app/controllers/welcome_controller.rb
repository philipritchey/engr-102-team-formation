class WelcomeController < ApplicationController
    skip_before_action :require_login, only: [:index]
    def index
        if logged_in?
          redirect_to user_path(@current_user), notice: 'Welcome, back!'
        else
          # This will render the welcome page (index view)
          # You can also add any logic to show on the welcome page
        end
      end
end
