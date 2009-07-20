class PublicationExpensesController < ApplicationController
  # GET /publication_expenses
  # GET /publication_expenses.xml
  def index
    @publication_expenses = PublicationExpense.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @publication_expenses }
    end
  end

  # GET /publication_expenses/1
  # GET /publication_expenses/1.xml
  def show
    @publication_expense = PublicationExpense.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @publication_expense }
    end
  end

  # GET /publication_expenses/new
  # GET /publication_expenses/new.xml
  def new
    @publication_expense = PublicationExpense.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @publication_expense }
    end
  end

  # GET /publication_expenses/1/edit
  def edit
    @publication_expense = PublicationExpense.find(params[:id])
  end

  # POST /publication_expenses
  # POST /publication_expenses.xml
  def create
    @publication_expense = PublicationExpense.new(params[:publication_expense])

    respond_to do |format|
      if @publication_expense.save
        flash[:notice] = 'Publication expense was successfully created.'
        format.html { redirect_to(@publication_expense) }
        format.xml  { render :xml => @publication_expense, :status => :created, :location => @publication_expense }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @publication_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /publication_expenses/1
  # PUT /publication_expenses/1.xml
  def update
    @publication_expense = PublicationExpense.find(params[:id])

    respond_to do |format|
      if @publication_expense.update_attributes(params[:publication_expense])
        flash[:notice] = 'PublicationExpense was successfully updated.'
        format.html { redirect_to(@publication_expense) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @publication_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /publication_expenses/1
  # DELETE /publication_expenses/1.xml
  def destroy
    @publication_expense = PublicationExpense.find(params[:id])
    @publication_expense.destroy

    respond_to do |format|
      format.html { redirect_to(publication_expenses_url) }
      format.xml  { head :ok }
    end
  end
end

