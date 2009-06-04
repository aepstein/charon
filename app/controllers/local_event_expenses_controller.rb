class LocalEventExpensesController < ApplicationController
  # GET /local_event_expenses
  # GET /local_event_expenses.xml
  def index
    @local_event_expenses = LocalEventExpense.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @local_event_expenses }
    end
  end

  # GET /local_event_expenses/1
  # GET /local_event_expenses/1.xml
  def show
    @local_event_expense = LocalEventExpense.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @local_event_expense }
    end
  end

  # GET /local_event_expenses/new
  # GET /local_event_expenses/new.xml
  def new
    @local_event_expense = LocalEventExpense.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @local_event_expense }
    end
  end

  # GET /local_event_expenses/1/edit
  def edit
    @local_event_expense = LocalEventExpense.find(params[:id])
  end

  # POST /local_event_expenses
  # POST /local_event_expenses.xml
  def create
    @local_event_expense = LocalEventExpense.new(params[:local_event_expense])

    respond_to do |format|
      if @local_event_expense.save
        flash[:notice] = 'LocalEventExpense was successfully created.'
        format.html { redirect_to(@local_event_expense) }
        format.xml  { render :xml => @local_event_expense, :status => :created, :location => @local_event_expense }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @local_event_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /local_event_expenses/1
  # PUT /local_event_expenses/1.xml
  def update
    @local_event_expense = LocalEventExpense.find(params[:id])

    respond_to do |format|
      if @local_event_expense.update_attributes(params[:local_event_expense])
        flash[:notice] = 'LocalEventExpense was successfully updated.'
        format.html { redirect_to(@local_event_expense) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @local_event_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /local_event_expenses/1
  # DELETE /local_event_expenses/1.xml
  def destroy
    @local_event_expense = LocalEventExpense.find(params[:id])
    @local_event_expense.destroy

    respond_to do |format|
      format.html { redirect_to(local_event_expenses_url) }
      format.xml  { head :ok }
    end
  end
end
