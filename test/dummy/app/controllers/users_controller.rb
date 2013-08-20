class UsersController < ApplicationController

  helper FileUpload::TagHelper

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
    else
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
    else
    end
  end

  protected

  def user_params
    params.require(:user).permit(:name)
  end
end