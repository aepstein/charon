authorization do

  role :admin do

    has_permission_on [ :activity_accounts, :activity_reports, :addresses,
      :agreements, :approvers, :fund_sources, :categories, :document_types,
      :fund_editions, :fund_grants, :fund_items, :fund_requests, :fund_sources,
      :frameworks, :fulfillments, :inventory_items, :nodes, :organizations,
      :registration_criterions, :registrations, :registration_terms, :roles,
      :structures, :university_accounts, :users, :user_state_criterions ],
      :to => [ :manage ]

    has_permission_on [ :approvals ], :to => [ :show, :destroy ]

    has_permission_on :authorization_rules, :to => :read

    has_permission_on [ :fund_sources ], :to => [ :review ]

    has_permission_on [ :fund_requests, :agreements ], :to => [ :unapprove ]
    has_permission_on [ :fund_requests ], :to => [ :submit ] do
      if_attribute :state => is_in { %w( tentative finalized ) }
    end
    has_permission_on [ :fund_requests ], :to => [ :reject ] do
      if_attribute :state => is_in { %w( finalized submitted ) }
    end
    has_permission_on [ :fund_requests ], :to => [ :withdraw ] do
      if_attribute :state => is_in { %w( tentative finalized submitted ) }
    end

    has_permission_on [ :memberships ], :to => :manage do
      if_attribute :registration_id => is { nil }
    end

    has_permission_on [ :registrations ], :to => [ :match ] do
      if_attribute :organization_id => is { nil }
    end

    has_permission_on [ :users ], :to => [ :admin ]

  end

  role :user do
    has_permission_on [ :agreements, :approvers, :categories, :document_types,
      :frameworks, :nodes, :organizations, :registration_criterions,
      :registration_terms, :roles, :structures, :user_state_criterions ],
      :to => [ :show ]

    has_permission_on [ :account_adjustments ], :to => :manage do
      if_permitted_to :manage, :activity_account
    end
    has_permission_on [ :account_adjustments ], :to => :show do
      if_permitted_to :show, :activity_account
    end

    has_permission_on [ :account_transactions ], :to => :manage do
      if_permitted_to :manage, :account_adjustments
    end
    has_permission_on [ :account_transactions ], :to => :show do
      if_permitted_to :show, :account_adjustments
    end

    has_permission_on [ :activity_accounts ], :to => :manage do
      if_permitted_to :manage, :fund_source
    end
    has_permission_on [ :activity_accounts ], :to => :show do
      if_permitted_to :request, :university_account
      if_permitted_to :manage, :university_account
    end

    has_permission_on [ :activity_reports ], :to => :manage do
      if_permitted_to :request, :organization
    end

    has_permission_on [ :agreements ], :to => :approve

    has_permission_on [ :approvals ], :to => [ :new, :create ], :join_by => :and do
      if_permitted_to :approve, :approvable
      if_attribute :user_id => is { user.id }
      if_attribute :approvable_type => is { 'Agreement' }, :approvable_id => is_not_in { user.approvals.agreement_ids }
    end
    has_permission_on [ :approvals ], :to => [ :new, :create ], :join_by => :and do
      if_permitted_to :approve, :approvable
      if_attribute :user_id => is { user.id }
      if_attribute :approvable_type => is { 'Request' }, :approvable_id => is_not_in { user.approvals.fund_request_ids }
    end
    has_permission_on [ :approvals ], :to => [ :destroy ], :join_by => :and do
      if_permitted_to :unapprove, :approvable
      if_attribute :user_id => is { user.id }
    end
    has_permission_on [ :approvals ], :to => [ :destroy ] do
      if_permitted_to :manage, :approvable
    end
    has_permission_on [ :approvals ], :to => [ :show ] do
      if_attribute :user_id => is { user.id }
    end
    has_permission_on [ :approvals ], :to => [ :show ], :join_by => :and do
      if_permitted_to :show, :approvable
      if_attribute :approvable_type => is { 'Request' }
    end

    has_permission_on [ :documents ], :to => :manage do
      if_permitted_to :manage, :fund_edition
    end
    has_permission_on [ :documents ], :to => :show do
      if_permitted_to :show, :fund_edition
    end

    has_permission_on [ :fulfillments ], :to => :show do
      if_attribute :fulfiller_type => is { 'Organization' }
      if_attribute :fulfiller_type => is { 'User' }, :fulfiller_id => is { user.id }
    end

    has_permission_on [ :fund_items ], :to => :allocate do
      if_permitted_to :allocate, :fund_grant
    end
    has_permission_on [ :fund_items ], :to => :request do
      if_permitted_to :request, :fund_grant
    end
    has_permission_on [ :fund_items ], :to => :manage do
      if_permitted_to :manage, :fund_grant
    end
    has_permission_on [ :fund_items ], :to => :review do
      if_permitted_to :review, :fund_grant
    end
    has_permission_on [ :fund_items ], :to => :update, :join_by => :and do
      if_permitted_to :review, :fund_grant
    end
    has_permission_on [ :fund_items ], :to => :show do
      if_permitted_to :show, :fund_grant
    end

    has_permission_on [ :fund_editions ], :to => :manage, :join_by => :and do
      if_permitted_to :update, :fund_item
      if_attribute :perspective => is { FundEdition::PERSPECTIVES.first }
    end
    has_permission_on [ :fund_editions ], :to => :manage, :join_by => :and do
      if_permitted_to :review, :fund_item
      if_attribute :fund_item => { :fund_request => { :state => is_in { %w( accepted ) } } }
    end
    has_permission_on [ :fund_editions ], :to => :manage, :join_by => :and do
      if_permitted_to :allocate, :fund_item
    end
    has_permission_on [ :fund_editions ], :to => :show, :join_by => :and do
      if_permitted_to :show, :fund_item
      if_attribute :perspective => is { FundEdition::PERSPECTIVES.first }
    end
    has_permission_on [ :fund_editions ], :to => :show, :join_by => :and do
      if_permitted_to :review, :fund_item
    end
    has_permission_on [ :fund_editions ], :to => :show, :join_by => :and do
      if_permitted_to :show, :fund_item
      if_attribute :fund_item => { :fund_request => { :state => is { 'released' } } }
    end

    has_permission_on [ :fund_grants ], :to => [ :show, :request_framework],
      :join_by => :and do
      if_permitted_to :request, :organization
    end
    has_permission_on [ :fund_grants ], :to => :request, :join_by => :and do
      if_permitted_to :request_framework
      if_attribute :fund_source => { :open_at => lt { Time.zone.now },
        :closed_at => gt { Time.zone.now } }
      if_attribute :fund_source => {
          :framework_id => is_in { user.frameworks( FundEdition::PERSPECTIVES.first,
            object.organization ).map(&:id)
          }
        }
    end
    has_permission_on [ :fund_grants ], :to => [ :show, :review_framework ],
      :join_by => :and do
      if_permitted_to :review, :fund_source
      if_attribute :organization_id => is_not_in { user.organization_ids }
    end
    has_permission_on [ :fund_grants ], :to => :review, :join_by => :and do
      if_permitted_to :review_framework
      if_attribute :fund_source => { :open_at => lt { Time.zone.now },
        :closed_at => gt { Time.zone.now } }
      if_attribute :fund_source => {
          :framework_id => is_in { user.frameworks( FundEdition::PERSPECTIVES.last,
            object.fund_source.organization ).map(&:id)
          }
        }
    end
    has_permission_on [ :fund_grants ], :to => [ :create ], :join_by => :and do
      if_permitted_to :request, :organization
      if_attribute :fund_source_id => is { nil }
    end
    has_permission_on [ :fund_grants ], :to => [ :create ], :join_by => :and do
      if_permitted_to :request
      if_attribute :fund_source => { :fund_queues => {
        :submit_at => gt { Time.zone.now } } }
    end
    has_permission_on [ :fund_grants ], :to => [ :manage, :show, :allocate ] do
      if_permitted_to :manage, :fund_source
    end

    has_permission_on [ :fund_requests ], :to => :request do
      if_permitted_to :request, :fund_grant
    end
    has_permission_on [ :fund_requests ], :to => :review do
      if_permitted_to :review, :fund_grant
    end
    has_permission_on [ :fund_requests ], :to => :show do
      if_permitted_to :show, :fund_grant
    end
    has_permission_on [ :fund_requests ], :to => [ :manage, :show, :allocate ] do
      if_permitted_to :manage, :fund_grant
    end
    has_permission_on [ :fund_requests ], :to => [ :create, :update ], :join_by => :and do
      if_permitted_to :request
      if_attribute :state => is_in { %w( started ) }
    end
    has_permission_on [ :fund_requests ], :to => :approve, :join_by => :and do
      if_permitted_to :request
      if_attribute :state => is_in { %w( started tentative ) }
    end
    has_permission_on [ :fund_requests ], :to => :unapprove do
      if_attribute :approvals => { :user_id => is { user.id } },
        :state => is_in { %w( tentative ) }
    end
    has_permission_on [ :fund_requests ], :to => :approve, :join_by => :and do
      if_permitted_to :review
      if_attribute :state => is_in { %w( submitted ) }
      if_attribute :review_state => is_in { %w( unreviewed tentative ) }
    end
    has_permission_on [ :fund_requests ], :to => :unapprove, :join_by => :and do
      if_permitted_to :review
      if_attribute :approvals => { :user_id => is { user.id } }
      if_attribute :review_state => is_in { %w( tentative ) }
    end
    has_permission_on [ :fund_requests ], :to => :reject, :join_by => :and do
      if_permitted_to :manage
      if_attribute :state => is_in { %w( finalized submitted ) }
    end
    has_permission_on [ :fund_requests ], :to => :submit, :join_by => :and do
      if_permitted_to :manage
      if_attribute :state => is_in { %w( tentative finalized ) }
    end
    has_permission_on [ :fund_requests ], :to => :withdraw, :join_by => :and do
      if_permitted_to :request
      if_attribute :state => is_in { %w( tentative submitted finalized ) }
    end
    has_permission_on [ :fund_requests ], :to => :withdraw, :join_by => :and do
      if_permitted_to :manage
      if_attribute :state => is_in { %w( tentative submitted finalized ) }
    end

    has_permission_on [ :fund_sources ], :to => [ :review, :show ] do
      if_permitted_to :review, :organization
    end
    has_permission_on [ :fund_sources ], :to => :manage do
      if_permitted_to :manage, :organization
    end
    has_permission_on [ :fund_sources ], :to => :show do
      if_attribute :open_at => lte { Time.zone.today }
    end

    has_permission_on [ :memberships ], :to => :show do
      if_permitted_to :show, :user
      if_attribute :user => { :organizations => intersects_with { user.organizations } }
      if_attribute :user => { :registrations => intersects_with { user.registrations } }
    end

    has_permission_on [ :organizations ], :to => :request do
      if_attribute :memberships => { :user_id => is { user.id },
        :active => is { true }, :role => { :name => is_in { Role::REQUESTOR } } }
    end
    has_permission_on [ :organizations ], :to => :review do
      if_attribute :memberships => { :user_id => is { user.id },
        :active => is { true }, :role => { :name => is_in { Role::REVIEWER } } }
    end
    has_permission_on [ :organizations ], :to => [ :manage, :allocate ] do
      if_attribute :memberships => { :user_id => is { user.id },
        :active => is { true }, :role => { :name => is_in { Role::MANAGER } } }
    end

    has_permission_on :inventory_fund_items, :to => [ :show, :update ] do
      if_permitted_to :request, :organization
    end

    has_permission_on [ :registrations ], :to => [ :show ] do
      if_attribute :memberships => { :user_id => is { user.id } }
    end

    has_permission_on [ :university_accounts ], :to => :request do
      if_permitted_to :request, :organization
    end

    has_permission_on [ :university_accounts ], :to => :manage do
      if_permitted_to :manage, :organization
      if_permitted_to :manage, :activity_accounts
    end

    has_permission_on [ :users ], :to => [ :show, :edit, :update ] do
      if_attribute :id => is { user.id }
    end

  end

  role :guest do
    has_permission_on :user_sessions, :to => [ :new, :create ]
  end

end

privileges do
  privilege :request do
    includes :profile
  end
  privilege :review do
    includes :profile
  end
  privilege :approve do
    includes :show
  end
  #TODO should manage really include show? performance issues in queries
  privilege :manage do
    includes :create, :update, :destroy, :show, :profile
  end
  privilege :create do
    includes :new
  end
  privilege :update do
    includes :edit
  end
  privilege :show do
    includes :index
  end
  privilege :reject do
    includes :do_reject
  end
end

