class SystemSettingsController < ApplicationController

  before_action :only => [:show, :edit, :update] do
    authorize!(:manage, SystemSettings)
  end

  @model_class = SystemSettings

  include LoggerActions

  def show
    @page_name = t("system_settings.show")
    @primero_language = I18n.locale
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => I18n }
    end
  end

  #NOTE: By rule, there should only be 1 SystemSettings row
  #      So, the index only returns 1 record
  def index
    authorize!(:index, SystemSettings)
    respond_to do |format|
      if @system_settings.present?
        format.json { render json: { success: 1, settings: @system_settings }}
      else
        format.json { render json: { message: I18n.t("messages.system_settings_failed"), success: 0 }}
      end
    end
  end

  def edit
    @page_name = t("system_settings.edit")
  end

  def update
    if @system_settings.present?
      if (@system_settings.update_attributes(params[:system_settings].to_h))
        @system_settings.update_default_locale
      end
    end
    flash[:notice] = I18n.t("system_settings.updated")
    redirect_to edit_system_setting_path("administrator")
  end

end
