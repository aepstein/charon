class ActivityReportsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index, :past, :current, :future ]
  before_filter :new_activity_report_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :attribute_check => true
  filter_access_to :index, :past, :current, :future do
    permitted_to!( :show, @organization ) if @organization
    permitted_to!( :index )
  end

  def past
    @activity_reports = @activity_reports.past
    index
  end

  def current
    @activity_reports = @activity_reports.current
    index
  end

  def future
    @activity_reports = @activity_reports.future
    index
  end

  # GET /organizations/:organization_id/activity_reports
  # GET /organizations/:organization_id/activity_reports.xml
  def index
    @search = @activity_reports.search( params[:search] )
    @activity_reports = @search.paginate( :page => params[:page],
      :include => { :organization => { :memberships => :role } }
    )

    respond_to do |format|
      format.html { render :action => 'index' }
      format.csv { csv_index }
      format.xml  { render :xml => @activity_reports }
    end
  end

  # GET /activity_reports/1
  # GET /activity_reports/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @activity_report }
    end
  end

  # GET /organizations/:organization_id/activity_reports/new
  # GET /organizations/:organization_id/activity_reports/new.xml
  # TODO -- should this action exist?
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity_report }
    end
  end

  # POST /organizations/:organization_id/activity_reports
  # POST /organizations/:organization_id/activity_reports.xml
  def create
    respond_to do |format|
      if @activity_report.save
        flash[:notice] = 'Activity report was successfully created.'
        format.html { redirect_to @activity_report }
        format.xml  { render :xml => @activity_report, :status => :created, :location => @activity_report }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity_report.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /activity_reports/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # PUT /activity_reports/1
  # PUT /activity_reports/1.xml
  def update
    respond_to do |format|
      if @activity_report.update_attributes(params[:activity_report])
        flash[:notice] = 'Activity report was successfully updated.'
        format.html { redirect_to @activity_report }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity_report.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /activity_reports/1
  # DELETE /activity_reports/1.xml
  def destroy
    @activity_report.destroy

    respond_to do |format|
      flash[:notice] = 'Activity report was successfully destroyed.'
      format.html { redirect_to( profile_url ) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @organization = Organization.find params[:organization_id] if params[:organization_id]
    @context ||= @organization
    @activity_report = ActivityReport.find params[:id] if params[:id]
  end

  def initialize_index
    @activity_reports = ActivityReport
    @activity_reports = @activity_reports.scoped( :conditions => { :organization_id => @organization.id } ) if @organization
    @activity_reports = @activity_reports.with_permissions_to(:show)
  end

  def new_activity_report_from_params
    @activity_report = @organization.activity_reports.build( params[:activity_report] )
  end

  def csv_index
    csv_string = CSV.generate do |csv|
      csv << %w( organization description starts_on ends_on )
      @activity_reports.each do |activity_report|
        next unless permitted_to?( :review, activity_report )
        csv << [ activity_report.organization.name,
          activity_report.description,
          activity_report.starts_on.to_formatted_s( :rfc822 ),
          activity_report.ends_on.to_formatted_s( :rfc822 ) ]
      end
    end
    send_data csv_string, :disposition => "attachment; filename=activity_reports.csv"
  end

end

