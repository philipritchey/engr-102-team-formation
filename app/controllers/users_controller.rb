# This controller manages user-specific actions
# Currently, it handles displaying a user's profile and associated forms
class UsersController < ApplicationController
  # GET /users/:id
  # Displays the user's profile page, including their forms
  def show
    # Retrieve all forms associated with the current user
    # This makes @forms available in the view, allowing us to display the user's forms
    @forms = current_user.forms
    # The corresponding view (app/views/users/show.html.erb) will have access to @forms
  end
end
