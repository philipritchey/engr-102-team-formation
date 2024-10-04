class UsersController < ApplicationController
  def show
    @forms = current_user.forms
  end
end
