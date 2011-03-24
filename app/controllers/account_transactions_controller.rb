class AccountTransactionsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_account_transaction_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :attribute_check => true
  filter_access_to :index do
    permitted_to!( :show, @activity_account ) if @activity_account
    true
  end

  # GET /account_transactions
  # GET /account_transactions.xml
  def index
    @account_transactions = AccountTransaction.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @account_transactions }
    end
  end

  # GET /account_transactions/1
  # GET /account_transactions/1.xml
  def show
    @account_transaction = AccountTransaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account_transaction }
    end
  end

  # GET /account_transactions/new
  # GET /account_transactions/new.xml
  def new
    @account_transaction = AccountTransaction.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account_transaction }
    end
  end

  # GET /account_transactions/1/edit
  def edit
    @account_transaction = AccountTransaction.find(params[:id])
  end

  # POST /account_transactions
  # POST /account_transactions.xml
  def create
    @account_transaction = AccountTransaction.new(params[:account_transaction])

    respond_to do |format|
      if @account_transaction.save
        format.html { redirect_to(@account_transaction, :notice => 'Account transaction was successfully created.') }
        format.xml  { render :xml => @account_transaction, :status => :created, :location => @account_transaction }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @account_transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /account_transactions/1
  # PUT /account_transactions/1.xml
  def update
    @account_transaction = AccountTransaction.find(params[:id])

    respond_to do |format|
      if @account_transaction.update_attributes(params[:account_transaction])
        format.html { redirect_to(@account_transaction, :notice => 'Account transaction was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account_transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /account_transactions/1
  # DELETE /account_transactions/1.xml
  def destroy
    @account_transaction = AccountTransaction.find(params[:id])
    @account_transaction.destroy

    respond_to do |format|
      format.html { redirect_to(account_transactions_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @activity_account = ActivityAccount.find params[:activity_account_id] if params[:activity_account_id]
    @account_transaction = AccountTransaction.find params[:id] if params[:id]
  end

  def initialize_index
    @account_transactions = AccountTransaction.scoped
    @account_transactions = @activity_account.account_transactions if @activity_account
  end

  def new_account_transaction_from_params
    @account_transaction = @activity_account.account_transactions.build( params[ :account_transaction ] )
    if @activity_account &&
      @account_transaction.adjustments.for_activity_account( @activity_account ).blank?
      @account_transaction.adjustments.build( :activity_account => @activity_account )
    end
  end

end

