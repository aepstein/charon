class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def index
    @users = User.search(params[:query])
    flash[:message] = "There were no people matching " +
    						 "<em>#{params[:query]}</em>." if @users.empty?
    redirect_to user_path(@users.first) if @users.size == 1
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end

  def show
      begin
      @person = User.find( params[:id], :include => :organizations )
    rescue ActiveRecord::RecordNotFound
      redirect_to user_path
  end

   def edit
    @user = User.find(params[:id])
    raise AuthorizationError unless current_user.may_update?(@user)
  end

  def update
  @user = User.find(params[:id])
    raise AuthorizationError unless current_user.may_update?(@user)

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Person was successfully updated.'
        format.html { if @user == current_user then
                        redirect_to( :controller => 'organizations',
                                     :action => 'overview' )
                      else
                        redirect_to user_url(@user)
                      end }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end
end
end

