class PopulateFundRequestTypeIdInFundRequests < ActiveRecord::Migration
  class FundRequestType < ActiveRecord::Base
    has_and_belongs_to_many :fund_queues
  end

  class FundQueue < ActiveRecord::Base
    has_and_belongs_to_many :fund_request_types
    has_many :fund_requests
  end

  class FundRequest < ActiveRecord::Base
    belongs_to :fund_request_type
  end

  def up
    FundRequestType.reset_column_information
    type = FundRequestType.find_or_create_by_name 'Unrestricted'
    FundQueue.all.each do |fund_queue|
      unless fund_queue.fund_request_types.include? type
        fund_queue.fund_request_types << type
      end
    end
    FundRequest.where( :fund_request_type_id => nil ).
      update_all( :fund_request_type_id => type.id )
    change_column :fund_requests, :fund_request_type_id, :integer, :null => false
  end

  def down
    change_column :fund_requests, :fund_request_type_id, :integer, :null => true
  end
end

