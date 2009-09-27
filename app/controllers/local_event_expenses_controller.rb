class LocalEventExpensesController < ApplicationController
  before_filter :require_user

  def index
    @events = LocalEventExpense.find( :all, :include => { :version => { :item => { :request => { :organizations => :users } } } },
      :conditions => ['versions.perspective = ? AND local_event_expenses.date >= ?', 'reviewer', Date.today - 1.weeks],
      :order => 'local_event_expenses.date ASC' )
    page = params[:page] ? params[:page] : 1
    respond_to do |format|
      format.html { @events = @events.paginate( :page => page ) }
    end
  end
end

