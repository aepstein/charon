class DocumentsController < ApplicationController
  before_filter :require_user, :initialize_context
  filter_access_to :show, :attribute_check => true
  filter_access_to :original do
    permitted_to! :show, @document
  end

  # GET /documents/:id
  # GET /documents/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @agreement }
    end
  end

  # GET /documents/:id/original.pdf
  def original
    respond_to do |format|
      format.pdf {
        send_file @document.original.path, :type => :pdf, :disposition => 'inline'
      }
    end
  end

  private

  def initialize_context
    @document = Document.find(params[:id]) if params[:id]
  end

end

