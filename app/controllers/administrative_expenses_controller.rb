class AdministrativeExpensesController < ApplicationController
  # GET /administrative_expenses
  # GET /administrative_expenses.xml
  def index
    @administrative_expenses = AdministrativeExpense.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @administrative_expenses }
    end
  end

  # GET /administrative_expenses/1
  # GET /administrative_expenses/1.xml
  def show
    @administrative_expense = AdministrativeExpense.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @administrative_expense }
    end
  end

  # GET /administrative_expenses/new
  # GET /administrative_expenses/new.xml
  def new
    @administrative_expense = AdministrativeExpense.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @administrative_expense }
    end
  end

  # GET /administrative_expenses/1/edit
  def edit
    @administrative_expense = AdministrativeExpense.find(params[:id])
  end

  # POST /administrative_expenses
  # POST /administrative_expenses.xml
  def create
    @administrative_expense = AdministrativeExpense.new(params[:administrative_expense])

    respond_to do |format|
      if @administrative_expense.save
        flash[:notice] = 'AdministrativeExpense was successfully created.'
        format.html { redirect_to(@administrative_expense) }
        format.xml  { render :xml => @administrative_expense, :status => :created, :location => @administrative_expense }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @administrative_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /administrative_expenses/1
  # PUT /administrative_expenses/1.xml
  def update
    @administrative_expense = AdministrativeExpense.find(params[:id])

    respond_to do |format|
      if @administrative_expense.update_attributes(params[:administrative_expense])
        flash[:notice] = 'AdministrativeExpense was successfully updated.'
        format.html { redirect_to(@administrative_expense) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @administrative_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /administrative_expenses/1
  # DELETE /administrative_expenses/1.xml
  def destroy
    @administrative_expense = AdministrativeExpense.find(params[:id])
    @administrative_expense.destroy

    respond_to do |format|
      format.html { redirect_to(administrative_expenses_url) }
      format.xml  { head :ok }
    end
  end
end
