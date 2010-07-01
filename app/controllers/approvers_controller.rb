class ApproversController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_approver_from_params, :only => [ :new, :create ]
  filter_access_to :show, :edit, :update, :new, :create, :destroy, :attribute_check => true
  filter_access_to :index do
    permitted_to!( :show, @framework )
  end

  # GET /framework/:framework_id/approvers
  # GET /framework/:framework_id/approvers.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @approvers }
    end
  end

  # GET /approvers/1
  # GET /approvers/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @approver }
    end
  end

  # GET /framework/:framework_id/approvers/new
  # GET /framework/:framework_id/approvers/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @approver }
    end
  end

  # GET /approvers/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /framework/:framework_id/approvers
  # POST /framework/:framework_id/approvers.xml
  def create
    respond_to do |format|
      if @approver.save
        flash[:notice] = 'Approver was successfully created.'
        format.html { redirect_to(@approver) }
        format.xml  { render :xml => @approver, :status => :created, :location => @approver }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @approver.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /approvers/1
  # PUT /approvers/1.xml
  def update
    respond_to do |format|
      if @approver.update_attributes(params[:approver])
        flash[:notice] = 'Approver was successfully updated.'
        format.html { redirect_to(@approver) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @approver.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /approvers/1
  # DELETE /approvers/1.xml
  def destroy
    @approver.destroy

    respond_to do |format|
      format.html { redirect_to( framework_approvers_url(@approver.framework) ) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @framework = Framework.find params[:framework_id] if params[:framework_id]
    @approver = Approver.find params[:id] if params[:id]
  end

  def initialize_index
    @approvers = @framework.approvers
  end

  def new_approver_from_params
    @approver = @framework.approvers.build( params[:approver] )
  end
end

