class TailoredResumesController < ApplicationController
  before_action :set_application
  before_action :set_tailored_resume, only: [ :show, :update, :print ]

  def create
    result = Tailoring::GenerateResume.new(@application).call
    @tailored_resume = @application.tailored_resumes.create!(
      content: result.content,
      rationale: result.rationale
    )
    redirect_to application_tailored_resume_path(@application, @tailored_resume),
      notice: "Tailored resume generated."
  rescue StandardError => e
    Rails.logger.error("Tailoring failed for Application ##{@application.id}: #{e.message}")
    redirect_to @application, alert: "Tailoring failed: #{e.message}"
  end

  def show
  end

  def update
    @tailored_resume.update(tailored_resume_params)
    redirect_to application_tailored_resume_path(@application, @tailored_resume), notice: "Saved."
  end

  def print
    render layout: "print"
  end

  private

  def set_application
    @application = Application.find(params[:application_id])
  end

  def set_tailored_resume
    @tailored_resume = @application.tailored_resumes.find(params[:id])
  end

  def tailored_resume_params
    params.require(:tailored_resume).permit(:content, :rationale)
  end
end
