class BasesController < ApplicationController
  # GET /structures/:structure_id/bases
  # GET /structures/:structure_id/bases.xml
  def index
    @structure = Structure.find(params[:structure_id])
    @bases = @structure.bases

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bases }
    end
  end

  # GET /bases/1
  # GET /bases/1.xml
  def show
    @basis = Basis.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @basis }
    end
  end

  # GET /structures/:structure_id/bases/new
  # GET /structures/:structure_id/bases/new.xml
  def new
    @basis = Structure.find(params[:structure_id]).bases.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @basis }
    end
  end

  # GET /bases/1/edit
  def edit
    @basis = Basis.find(params[:id])
  end

  # POST /structures/:structure_id/bases
  # POST /structures/:structure_id/bases.xml
  def create
    @basis = Structure.find(params[:structure_id]).bases.build(params[:basis])

    respond_to do |format|
      if @basis.save
        flash[:notice] = 'Basis was successfully created.'
        format.html { redirect_to(@basis) }
        format.xml  { render :xml => @basis, :status => :created, :location => @basis }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @basis.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bases/1
  # PUT /bases/1.xml
  def update
    @basis = Basis.find(params[:id])

    respond_to do |format|
      if @basis.update_attributes(params[:basis])
        flash[:notice] = 'Basis was successfully updated.'
        format.html { redirect_to(@basis) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @basis.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bases/1
  # DELETE /bases/1.xml
  def destroy
    @basis = Basis.find(params[:id])
    @structure = @basis.structure
    @basis.destroy

    respond_to do |format|
      format.html { redirect_to(structure_bases_url(@structure)) }
      format.xml  { head :ok }
    end
  end
end

