class ApprovalsController < ApplicationController

  before_filter :require_user

  # GET /:approvable_class/:approvable_id/approvals
  # GET /:approvable_class/:approvable_id/approvals.xml
  def index
    raise AuthorizationError unless approvable.may_see? current_user
    @approvals = approvable.approvals

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @approvals }
    end
  end

  # GET /approvals/1
  # GET /approvals/1.xml
  def show
    @approval = Approval.find(params[:id])
    raise AuthorizationError unless @approval.may_see? current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @approval }
    end
  end

  # GET /:approvable_class/:approvable_id/approvals/new
  # GET /:approvable_class/:approvable_id/approvals/new.xml
  def new
    @approval = approvable.approvals.build
    @approval.as_of = approvable.updated_at
    @approval.user = current_user
    raise AuthorizationError unless @approval.may_create? current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @approval }
    end
  end

  # POST /:approvable_class/:approvable_id/approvals
  # POST /:approvable_class/:approvable_id/approvals.xml
  def create
    @approval = approvable.approvals.build(params[:approval])
    @approval.user = current_user
    raise AuthorizationError unless @approval.may_create? current_user

    respond_to do |format|
      if @approval.save
        flash[:notice] = 'Approval was successfully created.'
        format.html { redirect_to(@approval.approvable) }
        format.xml  { render :xml => @approval, :status => :created, :location => @approval }
      else
        @approval.as_of = approvable.updated_at
        format.html { render :action => 'new' }
        format.xml  { render :xml => @approval.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /approvals/1
  # DELETE /approvals/1.xml
  def destroy
    @approval = Approval.find(params[:id])
    raise AuthorizationError unless @approval.may_destroy? current_user
    @approval.destroy

    respond_to do |format|
      format.html {
        if current_user == @approval.user
          redirect_to @approval.approvable
        else
          redirect_to polymorphic_url [ @approval.approvable, :approvals ]
        end }
      format.xml  { head :ok }
    end
  end

private
  def approvable
    @approvable ||= case
    when params[:request_id] then Request.find(params[:request_id])
    when params[:agreement_id] then Agreement.find(params[:agreement_id])
    end
  end
end

