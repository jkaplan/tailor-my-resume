class MasterResumeController < ApplicationController
  before_action :set_master_resume

  def show
  end

  def edit
  end

  def update
    @master_resume.update(master_resume_params)
    redirect_to master_resume_path, notice: "Master resume saved."
  end

  def import
    file = params.require(:file)
    text = ResumeImport::ExtractText.new(file.to_io).call
    @master_resume.source_pdf.attach(file)
    @master_resume.update(content: text)
    redirect_to edit_master_resume_path, notice: "Imported from PDF — review and clean up the text below."
  rescue StandardError => e
    redirect_to edit_master_resume_path, alert: "Could not read that PDF: #{e.message}"
  end

  private

  def set_master_resume
    @master_resume = MasterResume.current
  end

  def master_resume_params
    params.require(:master_resume).permit(:content)
  end
end
