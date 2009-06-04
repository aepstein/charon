class SpeakerExpensesController < ApplicationController
  # GET /speaker_expenses
  # GET /speaker_expenses.xml
  def index
    @speaker_expenses = SpeakerExpense.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @speaker_expenses }
    end
  end

  # GET /speaker_expenses/1
  # GET /speaker_expenses/1.xml
  def show
    @speaker_expense = SpeakerExpense.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @speaker_expense }
    end
  end

  # GET /speaker_expenses/new
  # GET /speaker_expenses/new.xml
  def new
    @speaker_expense = SpeakerExpense.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @speaker_expense }
    end
  end

  # GET /speaker_expenses/1/edit
  def edit
    @speaker_expense = SpeakerExpense.find(params[:id])
  end

  # POST /speaker_expenses
  # POST /speaker_expenses.xml
  def create
    @speaker_expense = SpeakerExpense.new(params[:speaker_expense])

    respond_to do |format|
      if @speaker_expense.save
        flash[:notice] = 'SpeakerExpense was successfully created.'
        format.html { redirect_to(@speaker_expense) }
        format.xml  { render :xml => @speaker_expense, :status => :created, :location => @speaker_expense }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @speaker_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /speaker_expenses/1
  # PUT /speaker_expenses/1.xml
  def update
    @speaker_expense = SpeakerExpense.find(params[:id])

    respond_to do |format|
      if @speaker_expense.update_attributes(params[:speaker_expense])
        flash[:notice] = 'SpeakerExpense was successfully updated.'
        format.html { redirect_to(@speaker_expense) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @speaker_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /speaker_expenses/1
  # DELETE /speaker_expenses/1.xml
  def destroy
    @speaker_expense = SpeakerExpense.find(params[:id])
    @speaker_expense.destroy

    respond_to do |format|
      format.html { redirect_to(speaker_expenses_url) }
      format.xml  { head :ok }
    end
  end
end
