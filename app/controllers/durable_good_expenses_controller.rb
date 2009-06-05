class DurableGoodExpensesController < ApplicationController
  # GET /durable_good_expenses
  # GET /durable_good_expenses.xml
  def index
    @durable_good_expenses = DurableGoodExpense.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @durable_good_expenses }
    end
  end

  # GET /durable_good_expenses/1
  # GET /durable_good_expenses/1.xml
  def show
    @durable_good_expense = DurableGoodExpense.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @durable_good_expense }
    end
  end

  # GET /durable_good_expenses/new
  # GET /durable_good_expenses/new.xml
  def new
    @durable_good_expense = DurableGoodExpense.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @durable_good_expense }
    end
  end

  # GET /durable_good_expenses/1/edit
  def edit
    @durable_good_expense = DurableGoodExpense.find(params[:id])
  end

  # POST /durable_good_expenses
  # POST /durable_good_expenses.xml
  def create
    @durable_good_expense = DurableGoodExpense.new(params[:durable_good_expense])

    respond_to do |format|
      if @durable_good_expense.save
        flash[:notice] = 'DurableGoodExpense was successfully created.'
        format.html { redirect_to(@durable_good_expense) }
        format.xml  { render :xml => @durable_good_expense, :status => :created, :location => @durable_good_expense }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @durable_good_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /durable_good_expenses/1
  # PUT /durable_good_expenses/1.xml
  def update
    @durable_good_expense = DurableGoodExpense.find(params[:id])

    respond_to do |format|
      if @durable_good_expense.update_attributes(params[:durable_good_expense])
        flash[:notice] = 'DurableGoodExpense was successfully updated.'
        format.html { redirect_to(@durable_good_expense) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @durable_good_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /durable_good_expenses/1
  # DELETE /durable_good_expenses/1.xml
  def destroy
    @durable_good_expense = DurableGoodExpense.find(params[:id])
    @durable_good_expense.destroy

    respond_to do |format|
      format.html { redirect_to(durable_good_expenses_url) }
      format.xml  { head :ok }
    end
  end
end
