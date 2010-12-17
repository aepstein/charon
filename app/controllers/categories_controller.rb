class CategoriesController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_category_from_params, :only => [ :new, :create ]
  filter_access_to :show, :destroy, :new, :create, :edit, :update, :attribute_check => true

  # GET /categories
  # GET /categories.xml
  def index
    @categories = @categories.paginate( :page => params[:page] )
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/new
  # GET /categories/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # POST /categories
  # POST /categories.xml
  def create
    respond_to do |format|
      if @category.save
        flash[:notice] = 'Category was successfully created.'
        format.html { redirect_to(@category) }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    respond_to do |format|
      if @category.update_attributes(params[:category])
        flash[:notice] = 'Category was successfully updated.'
        format.html { redirect_to(@category) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category.destroy

    respond_to do |format|
      format.html { redirect_to(categories_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @category = Category.find params[:id] if params[:id]
  end

  def initialize_index
    @categories = Category.scoped
  end

  def new_category_from_params
    @category = Category.new( params[:category] )
  end
end

