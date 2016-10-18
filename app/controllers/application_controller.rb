class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # make sure user is logged in before viewing site
  before_action :authenticate_user! 
end
