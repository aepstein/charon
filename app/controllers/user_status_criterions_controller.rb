class UserStatusCriterionsController < ApplicationController
  # GET /user_status_criterions
  # GET /user_status_criterions.xml
  def index
    @user_status_criterions = UserStatusCriterion.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_status_criterions }
    end
  end

  # GET /user_status_criterions/1
  # GET /user_status_criterions/1.xml
  def show
    @user_status_criterion = UserStatusCriterion.find(params[:id])
    raise AuthorizationError unless @user_status_criterion.may_see? current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_status_criterion }
    end
  end

  # GET /user_status_criterions/new
  # GET /user_status_criterions/new.xml
  def new
    @user_status_criterion = UserStatusCriterion.new
    raise AuthorizationError unless @user_status_criterion.may_create? current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_status_criterion }
    end
  end

  # GET /user_status_criterions/1/edit
  def edit
    @user_status_criterion = UserStatusCriterion.find(params[:id])
    raise AuthorizationError unless @user_status_criterion.may_update? current_user
  end

  # POST /user_status_criterions
  # POST /user_status_criterions.xml
  def create
    @user_status_criterion = UserStatusCriterion.new(params[:user_status_criterion])
    raise AuthorizationError unless @user_status_criterion.may_create? current_user

    respond_to do |format|
      if @user_status_criterion.save
        flash[:notice] = 'UserStatusCriterion was successfully created.'
        format.html { redirect_to(@user_status_criterion) }
        format.xml  { render :xml => @user_status_criterion, :status => :created, :location => @user_status_criterion }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_status_criterion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_status_criterions/1
  # PUT /user_status_criterions/1.xml
  def update
    @user_status_criterion = UserStatusCriterion.find(params[:id])
    raise AuthorizationError unless @user_status_criterion.may_update? current_user

    respond_to do |format|
      if @user_status_criterion.update_attributes(params[:user_status_criterion])
        flash[:notice] = 'UserStatusCriterion was successfully updated.'
        format.html { redirect_to(@user_status_criterion) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_status_criterion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_status_criterions/1
  # DELETE /user_status_criterions/1.xml
  def destroy
    @user_status_criterion = UserStatusCriterion.find(params[:id])
    raise AuthorizationError unless @user_status_criterion.may_destroy? current_user
    @user_status_criterion.destroy

    respond_to do |format|
      format.html { redirect_to(user_status_criterions_url) }
      format.xml  { head :ok }
    end
  end
end

