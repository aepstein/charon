class DurableGoodsAddendumsController < ApplicationController
  # GET /durable_goods_addendums
  # GET /durable_goods_addendums.xml
  def index
    @durable_goods_addendums = DurableGoodsAddendum.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @durable_goods_addendums }
    end
  end

  # GET /durable_goods_addendums/1
  # GET /durable_goods_addendums/1.xml
  def show
    @durable_goods_addendum = DurableGoodsAddendum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @durable_goods_addendum }
    end
  end

  # GET /durable_goods_addendums/new
  # GET /durable_goods_addendums/new.xml
  def new
    @durable_goods_addendum = DurableGoodsAddendum.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @durable_goods_addendum }
    end
  end

  # GET /durable_goods_addendums/1/edit
  def edit
    @durable_goods_addendum = DurableGoodsAddendum.find(params[:id])
  end

  # POST /durable_goods_addendums
  # POST /durable_goods_addendums.xml
  def create
    @durable_goods_addendum = DurableGoodsAddendum.new(params[:durable_goods_addendum])

    respond_to do |format|
      if @durable_goods_addendum.save
        flash[:notice] = 'DurableGoodsAddendum was successfully created.'
        format.html { redirect_to(@durable_goods_addendum) }
        format.xml  { render :xml => @durable_goods_addendum, :status => :created, :location => @durable_goods_addendum }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @durable_goods_addendum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /durable_goods_addendums/1
  # PUT /durable_goods_addendums/1.xml
  def update
    @durable_goods_addendum = DurableGoodsAddendum.find(params[:id])

    respond_to do |format|
      if @durable_goods_addendum.update_attributes(params[:durable_goods_addendum])
        flash[:notice] = 'DurableGoodsAddendum was successfully updated.'
        format.html { redirect_to(@durable_goods_addendum) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @durable_goods_addendum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /durable_goods_addendums/1
  # DELETE /durable_goods_addendums/1.xml
  def destroy
    @durable_goods_addendum = DurableGoodsAddendum.find(params[:id])
    @durable_goods_addendum.destroy

    respond_to do |format|
      format.html { redirect_to(durable_goods_addendums_url) }
      format.xml  { head :ok }
    end
  end
end
