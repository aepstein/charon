class LocalEventExpensesController < ApplicationController
  before_filter :require_user

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
            csv << ( [ local_event.date,
                       local_event.title,
                       local_event.location,
                       local_event.uup_required? ? 'Y' : 'N',
                       local_event.purpose,
                       local_event.requestors.map { |r| r.name }.join(", "),
                       local_event.requestors.map { |r| r.users }.flatten.uniq.map { |u| "#{u} (#{u.net_id})" }.join(", ") ] )
          end
        end
        send_data csv_string, :disposition => "attachment; filename=local_events.csv"
      end
    end
  end
end

