class ApproversController < ApplicationController
  # GET /framework/:framework_id/approvers
  # GET /framework/:framework_id/approvers.xml
  def index
    @framework = Framework.find(params[:framework_id])
    @approvers = @framework.approvers

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @approvers }
    end
  end

  # GET /approvers/1
  # GET /approvers/1.xml
  def show
    @approver = Approver.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @approver }
    end
  end

  # GET /framework/:framework_id/approvers/new
  # GET /framework/:framework_id/approvers/new.xml
  def new
    @approver = Framework.find(params[:framework_id]).approvers.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @approver }
    end
  end

  # GET /approvers/1/edit
  def edit
    @approver = Approver.find(params[:id])
  end

  # POST /framework/:framework_id/approvers
  # POST /framework/:framework_id/approvers.xml
  def create
    @approver = Framework.find(params[:framework_id]).approvers.build(params[:approver])

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
    @approver = Approver.find(params[:id])

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
    @approver = Approver.find(params[:id])
    @approver.destroy

    respond_to do |format|
      format.html { redirect_to(approvers_url) }
      format.xml  { head :ok }
    end
  end
end

