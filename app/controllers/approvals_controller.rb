class ApprovalsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_approval_from_params, :only => [ :new, :create ]
  filter_access_to :show, :new, :create, :destroy, :attribute_check => true
  filter_access_to :index do
    permitted_to!( :show, @user ) if @user
    permitted_to!( :show, @approvable ) if @approvable
  end

  # GET /:approvable_class/:approvable_id/approvals
  # GET /:approvable_class/:approvable_id/approvals.xml
  def index
    @search = @approvals.search( params[:search] )
    @approvals = @search.paginate( :page => params[:page] )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @approvals }
    end
  end

  # GET /approvals/1
  # GET /approvals/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @approval }
    end
  end

  # GET /:approvable_class/:approvable_id/approvals/new
  # GET /:approvable_class/:approvable_id/approvals/new.xml
  def new
    @approval.as_of = @approval.approvable.updated_at

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @approval }
    end
  end

  # POST /:approvable_class/:approvable_id/approvals
  # POST /:approvable_class/:approvable_id/approvals.xml
  def create
    respond_to do |format|
      if @approval.save
        flash[:notice] = 'Approval was successfully created.'
        format.html { redirect_to(@approval.approvable) }
        format.xml  { render :xml => @approval, :status => :created, :location => @approval }
      else
        @approval.as_of = @approval.approvable.updated_at
        format.html { render :action => 'new' }
        format.xml  { render :xml => @approval.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /approvals/1
  # DELETE /approvals/1.xml
  def destroy
    @approval.destroy

    respond_to do |format|
      format.html { redirect_to @approval.approvable }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @approval = Approval.find params[:id] if params[:id]
    @fund_request ||= FundRequest.find(params[:fund_request_id]) if params[:fund_request_id]
    @agreement ||= Agreement.find(params[:agreement_id]) if params[:agreement_id]
    @approvable = @fund_request || @agreement || @approval.approvable
    @user = User.find params[:user_id] if params[:user_id]
    add_breadcrumb @approvable, url_for( @approvable )
  end

  def initialize_index
    @approvals = Approval.scoped
    @approvals = @approvals.where( :approvable_type => @approvable.class.to_s,
      :approvable_id => @approvable.id ) if @approvable
    @approvals = @approvals.where( :user_id => @user.id ) if @user
    # Kludge to get index behavior correct without using with_permissions_to scope
    @approvals = @approvals.where( :user_id => current_user.id ) if @approvable.class == Agreement && !current_user.role_symbols.include?( :admin )
  end

  def new_approval_from_params
    @approval = @approvable.approvals.build( params[:approval] )
    @approval.user = current_user
  end
end

