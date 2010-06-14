authorization do
  role :admin do
    has_permission_on [ :addresses, :agreements, :approvers,
      :bases, :categories, :document_types, :editions, :frameworks, :fulfillments,
      :items, :nodes, :organizations, :permissions, :registration_criterions,
      :registrations, :requests, :roles, :structures, :users, :user_status_criterions ],
      :to => [ :manage ]
    has_permission_on [ :approvals ], :to => [ :show, :destroy ]
    has_permission_on [ :requests, :agreements ], :to => [ :unapprove ]
    has_permission_on [ :memberships ], :to => :manage do
      if_attribute :registration_id => is { nil }
    end
    has_permission_on :authorization_rules, :to => :read
  end
  role :user do
    has_permission_on [ :agreements, :approvers, :categories, :document_types,
      :frameworks, :nodes, :organizations, :registration_criterions,
      :roles, :structures, :user_status_criterions ], :to => [ :show ]

    has_permission_on [ :memberships ], :to => :show do
      if_permitted_to :show, :user
    end

    has_permission_on [ :users ], :to => [ :show ] do
      if_attribute :organizations => intersects_with { user.organizations }
    end
    has_permission_on [ :users ], :to => [ :show, :edit, :update ] do
      if_attribute :id => is { user.id }
    end

    has_permission_on [ :registrations ], :to => [ :show ] do
      if_attribute :memberships => { :user_id => is { user.id } }
    end

    has_permission_on [ :fulfillments ], :to => :show do
      if_attribute :fulfiller_type => is { 'Organization' }
      if_attribute :fulfiller_type => is { 'User' }, :fulfiller_id => is { user.id }
    end

    has_permission_on [ :organizations ], :to => :request do
      if_attribute :memberships => { :user_id => is { user.id }, :active => is { true }, :role => { :name => is_in { Role::REQUESTOR } } }
    end
    has_permission_on [ :organizations ], :to => :review do
      if_attribute :memberships => { :user_id => is { user.id }, :active => is { true }, :role => { :name => is_in { Role::REVIEWER } } }
    end
    has_permission_on [ :organizations ], :to => [ :manage, :allocate ] do
      if_attribute :memberships => { :user_id => is { user.id }, :active => is { true }, :role => { :name => is_in { Role::MANAGER } } }
    end

    has_permission_on [ :bases ], :to => :review do
      if_permitted_to :review, :organization
    end
    has_permission_on [ :bases ], :to => :manage do
      if_permitted_to :manage, :organization
    end
    # TODO Should only show bases that are open as of current date
    has_permission_on [ :bases ], :to => :show

    has_permission_on [ :requests ], :to => :show do
      if_permitted_to :request, :organization
    end
    has_permission_on [ :requests ], :to => :show do
      if_permitted_to :review, :basis
    end
    has_permission_on [ :requests ], :to => :show do
      if_permitted_to :manage, :basis
    end
    has_permission_on [ :requests ], :to => :allocate do
      if_permitted_to :manage, :basis
    end
    has_permission_on [ :requests ], :to => :request, :join_by => :and do
      if_permitted_to :request, :organization
      if_attribute :organization => { :framework_id => is_in { object.organization.frameworks( Edition::PERSPECTIVES.first ).map(&:id) } }
      if_attribute :basis => { :framework_id => is_in { user.framework_ids( Edition::PERSPECTIVES.first ) } }
    end
    has_permission_on [ :requests ], :to => :review, :join_by => :and do
      if_permitted_to :review, :basis
      if_attribute :organization_id => is_not_in { user.organization_ids }
      if_attribute :basis => { :framework_id => is_in { object.basis.organization.frameworks( Edition::PERSPECTIVES.last ).map(&:id) } }
      if_attribute :basis => { :framework_id => is_in { user.framework_ids( Edition::PERSPECTIVES.last ) } }
    end
    has_permission_on [ :requests ], :to => :manage do
      if_permitted_to :manage, :basis
    end
    has_permission_on [ :requests ], :to => :manage, :join_by => :and do
      if_permitted_to :request, :organization
      if_attribute :status => is_in { %w( started ) }
    end
    has_permission_on [ :requests ], :to => :approve, :join_by => :and do
      if_permitted_to :request, :organization
      if_attribute :status => is_in { %w( started completed ) }
    end
    has_permission_on [ :requests ], :to => :unapprove do
      if_attribute :status => is_in { %w( started completed ) }
    end
    has_permission_on [ :requests ], :to => :approve, :join_by => :and do
      if_permitted_to :review, :basis
      if_attribute :status => is_in { %w( accepted reviewed ) }
    end
    has_permission_on [ :requests ], :to => :unapprove, :join_by => :and do
      if_permitted_to :review, :basis
      if_attribute :status => is_in { %w( completed reviewed ) }
    end

    has_permission_on [ :items ], :to => :allocate do
      if_permitted_to :allocate, :request
    end
    has_permission_on [ :items ], :to => :request do
      if_permitted_to :request, :request
    end
    has_permission_on [ :items ], :to => :manage do
      if_permitted_to :manage, :request
    end
    has_permission_on [ :items ], :to => :review do
      if_permitted_to :review, :request
    end
    has_permission_on [ :items ], :to => :update, :join_by => :and do
      if_permitted_to :review, :request
      if_attribute :request => { :status => is_in { %w( accepted ) } }
    end
    has_permission_on [ :items ], :to => :show do
      if_permitted_to :show, :request
      if_permitted_to :review, :request
    end

    has_permission_on [ :editions ], :to => :manage, :join_by => :and do
      if_permitted_to :update, :item
      if_attribute :perspective => is { Edition::PERSPECTIVES.first }
    end
    has_permission_on [ :editions ], :to => :manage, :join_by => :and do
      if_permitted_to :review, :item
      if_attribute :item => { :request => { :status => is_in { %w( accepted ) } } }
    end
    has_permission_on [ :editions ], :to => :manage, :join_by => :and do
      if_permitted_to :allocate, :item
    end
    has_permission_on [ :editions ], :to => :show, :join_by => :and do
      if_permitted_to :show, :item
      if_attribute :perspective => is { Edition::PERSPECTIVES.first }
    end
    has_permission_on [ :editions ], :to => :show, :join_by => :and do
      if_permitted_to :review, :item
    end
    has_permission_on [ :editions ], :to => :show, :join_by => :and do
      if_permitted_to :show, :item
      if_attribute :item => { :request => { :status => is { 'released' } } }
    end

    has_permission_on [ :documents ], :to => :manage do
      if_permitted_to :manage, :edition
    end
    has_permission_on [ :documents ], :to => :show do
      if_permitted_to :show, :edition
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
      if_attribute :approvable_type => is { 'Request' }, :approvable_id => is_not_in { user.approvals.request_ids }
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
end

