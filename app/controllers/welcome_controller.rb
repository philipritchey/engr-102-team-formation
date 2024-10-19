class WelcomeController < ApplicationController
  skip_before_action :require_login, only: [ :index ]

  def index
    if logged_in?
      if current_user
        redirect_to user_path(current_user), notice: "Welcome back!" and return
      elsif current_student
        redirect_to student_path(current_student), notice: "Welcome back, Student!" and return
      end
    else
      # This will render the welcome page (index view) without redirecting
      render layout: false
    end
  end
end
