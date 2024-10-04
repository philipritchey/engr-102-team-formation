class UsersController < ApplicationController
  def show
    @current_user = User.find(params[:id])
    if @current_user
      # If the user is found, render the user's page (show view)
      render :show
    end
  end
end
