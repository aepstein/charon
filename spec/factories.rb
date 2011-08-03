module FactoryData
  ALLOWED_NODE_TYPES = %w( ExternalEquityReport AdministrativeExpense
    DurableGoodExpense LocalEventExpense PublicationExpense TravelEventExpense
    SpeakerExpense )
end

FactoryGirl.define do

  factory :account_adjustment do
    association :account_transaction
    association :activity_account
    amount 0.0
  end

  factory :account_transaction do
    effective_on { |t| Time.zone.today }
  end

  factory :activity_account do
    association :university_account
  end

  factory :activity_report do
    association :organization
    sequence( :description ) { |n| "activity #{n}" }
    number_of_grads 10
    number_of_undergrads 15
    number_of_others 0
    starts_on { |report| Time.zone.today - 1.month }
    ends_on { |report| report.starts_on + 1.day }

    factory :current_activity_report do
      starts_on { |report| Time.zone.today }
      ends_on { |report| report.starts_on + 1.day }
    end

    factory :future_activity_report do
      starts_on { |report| Time.zone.today + 1.month }
      ends_on { |report| report.starts_on + 1.day }
    end

  end

  factory :address do
    association :addressable, :factory => :user
    sequence(:label) { |n| "Address #{n}" }
  end

  factory :agreement do
    sequence(:name) { |n| "Agreement #{n}" }
    content "Text of an agreement"
    contact_name "a contact"
    contact_email "contact@example.com"
  end

  factory :approval do
    association :user
    association :approvable, :factory => :fund_request
    as_of { |approval| approval.approvable.updated_at + 1.second }
  end

  factory :approver do
    association :framework
    association :role
    perspective { FundEdition::PERSPECTIVES.first }
  end

  factory :category do
    sequence(:name) { |n| "Category #{n}" }
  end

  factory :document do
    original { Rack::Test::UploadedFile.new(
      "#{::Rails.root}/features/support/assets/small.pdf", 'application/pdf' ) }
    association :fund_edition, :factory => :attachable_fund_edition
    document_type { |d| d.fund_edition.fund_item.node.document_types.first }
  end

  factory :document_type do
    sequence(:name) { |n| "Document Type #{n}" }
    max_size_quantity 1
    max_size_unit DocumentType::UNITS.last
  end

  factory :framework do
    sequence(:name) { |n| "Sequence #{n}" }

    factory :safc_framework do
      must_register true
      member_percentage 60
      member_percentage_type 'undergrads'
    end

    factory :gpsafc_framework do
      must_register true
      member_percentage 40
      member_percentage_type 'grads'
    end
  end

  factory :fulfillment do
    fulfiller { |r| r.association(:user) }
    fulfillable { |r| r.association(:agreement) }
  end

  factory :fund_edition do
    amount 0.0
    perspective 'requestor'
    fund_request { |edition|
      if edition.fund_item
        g = edition.fund_item.fund_grant
        g.fund_requests.first || edition.association( :fund_request, :fund_grant => g )
      else
        edition.association( :fund_request )
      end
    }
    fund_item { |edition|
      edition.association( :fund_item, :fund_grant => edition.fund_request.fund_grant )
    }
    after_create { |edition|
      edition.fund_request.association(:fund_editions).reset
      edition.fund_item.association(:fund_editions).reset
    }

    factory :attachable_fund_edition do
      fund_item { |edition|
        edition.association :attachable_fund_item,
          :fund_grant => edition.fund_request.fund_grant
      }
    end

    FactoryData::ALLOWED_NODE_TYPES.each do |t|
      factory "#{t}FundEdition".underscore.to_sym do
        fund_item do |fund_edition|
          fund_edition.association "#{t}FundItem".underscore.to_sym,
            :fund_grant => fund_edition.fund_request.fund_grant
        end
      end
    end
  end

  factory :fund_grant do
    association :fund_source
    association :organization

    factory :upcoming_fund_grant do
      association :fund_source, :factory => :upcoming_fund_source
    end

    factory :closed_fund_grant do
      association :fund_source, :factory => :closed_fund_source
    end
  end

  factory :fund_item do
    association :fund_grant
    node { |fund_item|
      fund_item.association :node,
        :structure => fund_item.fund_grant.fund_source.structure
    }


    factory :attachable_fund_item do
      association :fund_grant
      node { |fund_item| fund_item.association(:attachable_node,
        :structure => fund_item.fund_grant.fund_source.structure) }
    end

    FactoryData::ALLOWED_NODE_TYPES.each do |t|
      factory "#{t}FundItem".underscore.to_sym do
        association :fund_grant
        node { |fund_item|
          fund_item.association("#{t}Node".underscore.to_sym,
            :structure => fund_item.fund_grant.fund_source.structure)
        }
      end
    end
  end

  factory :fund_queue do
    association :fund_source
    submit_at { |q| q.fund_source.closed_at + 1.minute }
    release_at { |q| q.submit_at + 1.week }
  end

  factory :fund_request do
    association :fund_grant
  end

  factory :fund_request_type do
    sequence( :name ) { |n| "Fund Request Type #{n}" }
  end

  factory :fund_source do
    sequence(:name) { |n| "FundSource #{n}" }
    association :organization
    association :framework
    association :structure
    open_at { |b| Time.zone.today - 1.days }
    closed_at { |b| b.open_at + 2.days }
    contact_name "a contact"
    contact_email "contact@example.com"
    contact_web "http://example.com"

    factory :closed_fund_source do
      open_at { Time.zone.today - 1.year }
      closed_at { |b| b.open_at + 2.days }
    end

    factory :upcoming_fund_source do
      open_at { Time.zone.today + 1.month }
      closed_at { |b| b.open_at + 2.days }
    end
  end

  factory :inventory_item do
    association :organization
    sequence(:identifier) { |n| "id##{n}" }
    description "Boots"
    acquired_on { Time.zone.today }
    scheduled_retirement_on { |r| r.acquired_on + 1.year }
    purchase_price 100.0
  end

  factory :organization do
    sequence(:last_name) { |n| "Organization #{n}"}

    factory :registered_organization do
      registrations { |o| [ o.association(:current_registration, :registered => true) ] }
      after_create { |o| o.association(:registrations).reset }
    end
  end

  factory :registration do
    sequence(:name) { |n| "Registered Organization #{n}" }
    sequence(:external_id) { |i| i }
    number_of_undergrads 1

    factory :current_registration do
      association :registration_term, :factory => :current_registration_term

      factory :eligible_registration do
        registered true
        number_of_undergrads 10
      end

      factory :safc_eligible_registration do
        registered true
        number_of_undergrads 50
      end

      factory :gpsafc_eligible_registration do
        registered true
        number_of_grads 50
      end
    end
  end

  factory :registration_term do
    sequence(:external_id) { |i| i }
    sequence(:description) { |n| "Registration term #{n}" }
    current false

    factory :current_registration_term do
      current true
    end
  end

  factory :registration_criterion do
    must_register true
    minimal_percentage 10
    type_of_member 'undergrads'
  end

  factory :requirement do
    association :framework
    association :fulfillable, :factory => :agreement

    factory :requestor_requirement do
      perspectives [ FundEdition::PERSPECTIVES.first ]
    end

    factory :reviewer_requirement do
      perspectives [ FundEdition::PERSPECTIVES.last ]
    end
  end

  factory :user do
    first_name "John"
    sequence(:last_name) { |n| "Doe #{n}"}
    sequence(:net_id) { |n| "zzz#{n}"}
    password "secret"
    password_confirmation { |u| u.password }
    status "undergrad"
    ldap_entry false
  end

  factory :user_status_criterion do
    statuses [ 'undergrad' ]
  end

  factory :role do
    sequence(:name) { |n| "role #{n}" }

    factory :requestor_role do
      name { Role::REQUESTOR.first }
    end

    factory :reviewer_role do
      name { Role::REVIEWER.first }
    end

    factory :manager_role do
      name { Role::MANAGER.first }
    end
  end

  factory :membership do
    active true
    association :user
    association :role
    association :organization
  end

  factory :node do
    sequence(:name) { |n| "node #{n}" }
    item_quantity_limit 1
    association :structure
    association :category

    factory :attachable_node do
      document_types { |node| [ node.association(:document_type) ] }
    end

    FactoryData::ALLOWED_NODE_TYPES.each do |t|
      factory "#{t}Node".underscore.to_sym do
        requestable_type t
      end
    end
  end

  factory :registered_membership, :class => 'Membership' do
    association :user
    association :role
    association :registration
  end

  factory :member_source do
    association :organization
    association :role
    minimum_votes 0
    external_committee_id 1
  end

  factory :structure do
    sequence(:name) { |n| "Structure #{n}" }
  end

  factory :university_account do
    association :organization
    department_code 'S52'
    sequence(:subledger_code) { |n| n.to_s.rjust( 4, '0' ) }
  end

  # Expense calculators
  factory :administrative_expense do
    association :fund_edition, :factory => :administrative_expense_fund_edition
    copies 100
    repairs_restocking 100
    mailbox_wsh 25
  end

  factory :durable_good_expense do
    association :fund_edition, :factory => :durable_good_expense_fund_edition
    description 'a durable good'
    quantity 1.5
    price 1.5
  end

  factory :local_event_expense do
    association :fund_edition, :factory => :local_event_expense_fund_edition
    date Time.zone.today + 2.months
    title 'An Event'
    location 'Willard Straight Hall'
    purpose 'To do something fun'
    number_of_attendees 50
    price_per_attendee 5.50
    copies_quantity 500
    services_cost 1102
  end

  factory :publication_expense do
    association :fund_edition, :factory => :publication_expense_fund_edition
    title 'Publication'
    number_of_issues 3
    copies_per_issue 500
    price_per_copy 4.00
    cost_per_issue 2809.09
  end

  factory :travel_event_expense do
    association :fund_edition, :factory => :travel_event_expense_fund_edition
    date Time.zone.today + 2.months
    title "A tournament"
    location 'Los Angeles, CA'
    purpose 'To compete'
    travelers_per_group 5
    number_of_groups 2
    distance 6388
    nights_of_lodging 3
    per_person_fees 25.00
    per_group_fees 125.00
  end

  factory :speaker_expense do
    association :fund_edition, :factory => :speaker_expense_fund_edition
    title 'An Important Person'
    distance 204
    number_of_travelers 1
    nights_of_lodging 10
    engagement_fee 1000
  end

  factory :external_equity_report do
    association :fund_edition, :factory => :external_equity_report_fund_edition
  end

end

