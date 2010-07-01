class EditionsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  filter_access_to :index do
    permitted_to!( :show, @request ) if @request
    permitted_to!( :index )
  end

  # GET /requests/:request_id/editions
  # GET /requests/:request_id/editions.xml
  def index
    @editions = @editions.paginate( :page => params[:page] )
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @editions }
    end
  end

  def initialize_context
    @request = Request.find params[:request_id] if params[:request_id]
    @editions = Edition.scoped( :include => { :item => { :request => [ { :basis => :organization }, :organization ] } } )
    @editions = @edtions.scoped( :conditions => ['requests.id = ?', @request.id] )
    @editions = @editions.with_permissions_to(:show)
  end

end

