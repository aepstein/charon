class DocumentsController < ApplicationController
  before_filter :require_user

  # GET /documents/1
  # GET /documents/1.xml
  def show
    @document = Document.find(params[:id])
    raise AuthorizationError unless @document.may_see? current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @agreement }
    end
  end

end

