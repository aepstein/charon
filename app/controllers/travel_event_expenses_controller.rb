class TravelEventExpensesController < ApplicationController
  # GET /travel_event_expenses
  # GET /travel_event_expenses.xml
  def index
    @travel_event_expenses = TravelEventExpense.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @travel_event_expenses }
    end
  end

  # GET /travel_event_expenses/1
  # GET /travel_event_expenses/1.xml
  def show
    @travel_event_expense = TravelEventExpense.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @travel_event_expense }
    end
  end

  # GET /travel_event_expenses/new
  # GET /travel_event_expenses/new.xml
  def new
    @travel_event_expense = TravelEventExpense.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @travel_event_expense }
    end
  end

  # GET /travel_event_expenses/1/edit
  def edit
    @travel_event_expense = TravelEventExpense.find(params[:id])
  end

  # POST /travel_event_expenses
  # POST /travel_event_expenses.xml
  def create
    @travel_event_expense = TravelEventExpense.new(params[:travel_event_expense])

    respond_to do |format|
      if @travel_event_expense.save
        flash[:notice] = 'TravelEventExpense was successfully created.'
        format.html { redirect_to(@travel_event_expense) }
        format.xml  { render :xml => @travel_event_expense, :status => :created, :location => @travel_event_expense }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @travel_event_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /travel_event_expenses/1
  # PUT /travel_event_expenses/1.xml
  def update
    @travel_event_expense = TravelEventExpense.find(params[:id])

    respond_to do |format|
      if @travel_event_expense.update_attributes(params[:travel_event_expense])
        flash[:notice] = 'TravelEventExpense was successfully updated.'
        format.html { redirect_to(@travel_event_expense) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @travel_event_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /travel_event_expenses/1
  # DELETE /travel_event_expenses/1.xml
  def destroy
    @travel_event_expense = TravelEventExpense.find(params[:id])
    @travel_event_expense.destroy

    respond_to do |format|
      format.html { redirect_to(travel_event_expenses_url) }
      format.xml  { head :ok }
    end
  end
end
