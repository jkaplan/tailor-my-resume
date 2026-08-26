class ActivityLogsController < ApplicationController
  def create
    @application = Application.find(params[:application_id])
    @application.activity_logs.create(activity_type: :note, body: params[:activity_log][:body])
    redirect_to @application
  end
end
