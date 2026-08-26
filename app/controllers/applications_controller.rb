class ApplicationsController < ApplicationController
  before_action :set_application, only: [ :show, :edit, :update, :destroy ]

  def index
    @applications = Application.order(created_at: :desc)
    @applications = @applications.where(status: params[:status]) if params[:status].present?
  end

  def show
    @contacts = @application.contacts.order(:name)
    @activity_logs = @application.activity_logs
    @tailored_resume = @application.current_tailored_resume
    @new_contact = Contact.new
  end

  def new
    @application = Application.new
  end

  def create
    @application = Application.new(application_params)
    if @application.save
      redirect_to @application, notice: "Application created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @application.update(application_params)
      redirect_to @application, notice: "Application updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @application.destroy
    redirect_to applications_path, notice: "Application removed."
  end

  private

  def set_application
    @application = Application.find(params[:id])
  end

  def application_params
    params.require(:application).permit(
      :company, :role_title, :job_url, :job_description,
      :status, :applied_date, :follow_up_date
    )
  end
end
