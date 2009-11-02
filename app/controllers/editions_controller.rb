class EditionsController < ApplicationController
  before_filter :require_user

  # GET /items/:item_id/editions
  # GET /items/:item_id/editions.xml
  def index
    @item = Item.find(params[:item_id])
    @editions = @item.editions
    raise AuthorizationError unless @item.may_see?(current_user)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @editions }
    end
  end

  # GET /editions/1
  # GET /editions/1.xml
  def show
    @edition = Edition.find(params[:id])
    raise AuthorizationError unless @edition.may_see?(current_user)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @edition }
    end
  end

  # GET /items/:item_id/editions/new
  # GET /items/:item_id/editions/new.xml
  def new
    @edition = Item.find(params[:item_id]).editions.next
    raise AuthorizationError unless @edition.may_create?(current_user)
    @edition.documents.populate

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @edition }
    end
  end

  # GET /editions/1/edit
  def edit
    @edition = Edition.find(params[:id])
    raise AuthorizationError unless @edition.may_update?(current_user)
  end

  # POST /items/:item_id/editions
  # POST /items/:item_id/editions.xml
  def create
    @edition = Item.find(params[:item_id]).editions.next(params[:edition])
    raise AuthorizationError unless @edition.may_see?(current_user)

    respond_to do |format|
      if @edition.save
        flash[:notice] = 'Edition was successfully created.'
        format.html { redirect_to(@edition) }
        format.xml  { render :xml => @edition, :status => :created, :location => @edition }
      else
        @edition.documents.populate
        format.html { render :action => "new" }
        format.xml  { render :xml => @edition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /editions/1
  # PUT /editions/1.xml
  def update
    @edition = Edition.find(params[:id])
    raise AuthorizationError unless @edition.may_update?(current_user)

    respond_to do |format|
      if @edition.update_attributes(params[:edition])
        flash[:notice] = 'Edition was successfully updated.'
        format.html { redirect_to(@edition) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @edition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /editions/1
  # DELETE /editions/1.xml
  def destroy
    @edition = Edition.find(params[:id])
    raise AuthorizationError unless @edition.may_destroy?(current_user)
    @edition.destroy

    respond_to do |format|
      format.html { redirect_to(editions_url) }
      format.xml  { head :ok }
    end
  end
end

