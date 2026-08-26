class ContactsController < ApplicationController
  before_action :set_application
  before_action :set_contact, only: [ :update, :destroy ]

  def create
    @contact = @application.contacts.new(contact_params)
    @contact.save
    redirect_to @application
  end

  def update
    @contact.update(contact_params)
    redirect_to @application
  end

  def destroy
    @contact.destroy
    redirect_to @application
  end

  private

  def set_application
    @application = Application.find(params[:application_id])
  end

  def set_contact
    @contact = @application.contacts.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:name, :role, :email, :phone, :notes)
  end
end
