class AddressesController < ApplicationController
  # GET /user/:user_id/addresses
  # GET /user/:user_id/addresses.xml
  def index
    raise AuthorizationError unless addressable.may_see? current_user
    @addresses = addressable.addresses

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @addresses }
    end
  end

  # GET /addresses/1
  # GET /addresses/1.xml
  def show
    @address = Address.find(params[:id])
    raise AuthorizationError unless @address.may_see? current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @address }
    end
  end

  # GET /user/:user_id/addresses/new
  # GET /user/:user_id/addresses/new.xml
  def new
    @address = addressable.addresses.build
    raise AuthorizationError unless @address.may_create? current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @address }
    end
  end

  # GET /addresses/1/edit
  def edit
    @address = Address.find(params[:id])
    raise AuthorizationError unless @address.may_update? current_user
  end

  # POST /user/:user_id/addresses
  # POST /user/:user_id/addresses.xml
  def create
    @address = addressable.addresses.build(params[:address])
    raise AuthorizationError unless @address.may_create? current_user

    respond_to do |format|
      if @address.save
        flash[:notice] = 'Address was successfully created.'
        format.html { redirect_to(@address) }
        format.xml  { render :xml => @address, :status => :created, :location => @address }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @address.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /addresses/1
  # PUT /addresses/1.xml
  def update
    @address = Address.find(params[:id])
    raise AuthorizationError unless @address.may_update? current_user

    respond_to do |format|
      if @address.update_attributes(params[:address])
        flash[:notice] = 'Address was successfully updated.'
        format.html { redirect_to(@address) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @address.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /addresses/1
  # DELETE /addresses/1.xml
  def destroy
    @address = Address.find(params[:id])
    raise AuthorizationError unless @address.may_destroy? current_user
    @address.destroy

    respond_to do |format|
      format.html { redirect_to( addressable_addresses_url(@address.addressable) ) }
      format.xml  { head :ok }
    end
  end

private

  def addressable_addresses_url(addressable)
    case addressable.class.to_s
    when "User"
      user_addresses_url(addressable)
    else
      raise "Class #{addressable.class} not supported"
    end
  end

  def addressable
    @addressable ||= User.find(params[:user_id])
  end
end

