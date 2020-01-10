class AgenciesController < ApplicationController

  @model_class = Agency

  include MediaActions
  include RecordFilteringPagination

  before_action :sanitize_multiselects, only: [:create, :update]
  before_action :filter_params_array_duplicates, :only => [:create, :update]
  before_action :load_record_or_redirect, :only => [ :show, :edit, :destroy, :update ]
  before_action :load_services, :only => [:new, :edit, :create, :update]
  before_action :load_agencies, :only => [:index]

  include LoggerActions

  def index
    authorize! :index, Agency
    @page_name = t("agencies.label")
    @filters = record_filter(filter)
    @total_records = @agencies_result.count
    per_page
    @agencies = paginated_collection(@agencies_result.try(:all), @agencies_result.count)
  end

  def search
    authorize! :search, Agency

    service_type = params[:service_type]
    agencies = if service_type.present?
                Agency.by_service.key(service_type).all
               else
                 Agency.all.all
               end

    respond_to do |format|
      format.json do
        render json: { success: 1, agencies: format_search_response(agencies) }
      end
    end
  end

  def show
    authorize! :view, @agency

    respond_to do |format|
      format.html
    end
  end

  def new
    authorize! :create, Agency
    @agency = Agency.new
  end

  def create
    authorize! :create, Agency
    @agency = Agency.new(params[:agency].to_h)

    if @agency.save
      redirect_to agencies_path, notice: t("agencies.successfully_created")
    else
      render :new
    end
  end

  def edit
    authorize! :update, Agency
  end

  def update
    authorize! :update, Agency

    @agency.update_attributes(params[:agency].to_h)

    if @agency.save
      redirect_to agencies_path, notice: t("agencies.successfully_updated")
    else
      flash[:error] = t("agencies.error_in_updating")
      render :action => "edit"
    end
  end

  def destroy
    authorize! :destroy, Agency
    @agency.destroy
    redirect_to agencies_path
  end

  def update_order
    agencies = Agency.all.all

    params['user-row-agency-row'].each_with_index do |id, index|
      agency = agencies.select{ |a| a.name == id }.first
      agency.update_attributes(order: index + 1)
    end

    render :json => ""
  end

  #Override method defined in record_filtering_pagination
  def per_page
    @per_page ||= params[:per] ? params[:per].to_i : 50
    @per_page
  end

  private

  def load_record_or_redirect
    @agency = Agency.get(params[:id]) if params[:id]
  end

  def load_services
    @services = Lookup.values_for_select('lookup-service-type')
  end

  def agency_status_param
    params.dig(:scope, :status).try(:split, '||')
  end

  def load_agencies
    filter_status = agency_status_param || %w(list enabled)
    agencies_result = (filter_status.length == 2) ? Agency.by_disabled(key: filter_status.last.eql?('disabled')) : Agency.all
    @agencies_result = agencies_result.try(:page, page).try(:per, per_page) || []
  end

  def record_filter(filter)
    filter["status"] ||= { type: 'list', value: 'enabled' }
    filter
  end

  def sanitize_multiselects
    sanitize_multiselect_params(:agency, [:services])
  end

  def format_search_response(agencies)
    agencies.map do |agency|
      attributes = agency.attributes.slice('id','agency_code', 'telephone', 'services')
      # id is not part of the attributes
      # name and description are localizable properties
      attributes.merge(id: agency.id, name: agency.name, description: agency.description)
    end
  end
end
