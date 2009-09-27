class LocalEventExpensesController < ApplicationController

  def index
    @events = LocalEventExpense.find( :all, :include => { :version => { :item => { :request => { :organizations => :users } } } },
      :conditions => ['versions.perspective = ? AND local_event_expenses.date >= ?', 'reviewer', Date.today - 1.weeks],
      :order => 'local_event_expenses.date ASC' )
    page = params[:page] ? params[:page] : 1
    respond_to do |format|
      format.html { @events = @events.paginate( :page => page ) }
      format.csv do
        csv_string = FasterCSV.generate do |csv|
          csv << %w( date title location uup purpose organizers contacts )
          @events.each do |event|
            csv << ( [ event.date,
                       event.title,
                       event.location,
                       event.uup_required? ? 'Y' : 'N',
                       event.purpose,
                       event.requestors.map { |r| r.name }.join(", "),
                       event.requestors.map { |r| r.users }.flatten.uniq.map { |u| "#{u} (#{u.net_id})" }.join(", ") ] )
          end
        end
        send_data csv_string, :disposition => "attachment; filename=local_events.csv"
      end
    end
  end
end

