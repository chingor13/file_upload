class EmailsController < ApplicationController
  helper FileUpload::TagHelper

  def index
    @emails = Email.all
  end

  def new
    @email = Email.new
  end

  def edit
    @email = Email.find(params[:id])
  end

  def create
    @email = Email.new(email_params)
    if @email.save
      redirect_to @email
    else
      render :new
    end
  end

  def update
    @email = Email.find(params[:id])
    if @user.update_attributes(email_params)
      redirect_to @email
    else
      render :edit
    end
  end

  def show
    @email = Email.find(params[:id])
  end

  protected

  def email_params
    params.require(:email).permit(:subject, :message, attachments_attributes: [:key])
  end

end