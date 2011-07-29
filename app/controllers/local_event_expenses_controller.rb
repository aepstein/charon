class LocalEventExpensesController < ApplicationController
  before_filter :require_user
  filter_access_to :index do
    current_user.admin?
  end

  def index
    @events = LocalEventExpense.scoped.includes(
      :fund_edition => { :fund_request => [],
        :fund_item => { :fund_grant => { :organization => :users } } } ).
      where('fund_editions.perspective = ? AND local_event_expenses.date >= ?',
        'reviewer', Date.today - 1.weeks ).
      order { date }
    page = params[:page] ? params[:page] : 1
    respond_to do |format|
      format.html { @events = @events.page(page) }
      format.csv do
        csv_string = CSV.generate do |csv|
          csv << %w( date title location uup purpose organizer contacts )
          @events.each do |event|
            csv << ( [ event.date,
                       event.title,
                       event.location,
                       event.uup_required? ? 'Y' : 'N',
                       event.purpose,
                       event.requestor.name,
                       event.requestor.users.uniq.map { |u| "#{u} (#{u.net_id})" }.join(", ") ] )
          end
        end
        send_data csv_string, :disposition => "attachment; filename=local_events.csv"
      end
    end
  end
end

