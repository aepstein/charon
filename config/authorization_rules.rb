authorization do
  role :admin do
    has_permission_on [ :addresses, :agreements, :approvals, :approvers,
      :bases, :categories, :document_types, :editions, :frameworks, :fulfillments,
      :items, :nodes, :organizations, :permissions, :registration_criterions,
      :registrations, :requests, :roles, :users ], :to => [ :manage ]
    has_permission_on [ :organizations, :requests, :items, :editions ], :to => [ :request, :review ]
    has_permission_on [ :requests, :agreements ], :to => [ :approve, :unapprove ]
    has_permission_on :authorization_rules, :to => :read
  end
  role :user do
    has_permission_on [ :agreements, :approvers, :categories, :document_types,
      :frameworks, :fulfillments, :items, :nodes, :organizations, :registration_criterions,
      :roles ], :to => [ :show ]
    has_permission_on [ :users ], :to => [ :edit, :update ] do
      if_attribute :id => is { user.id }
    end
    has_permission_on [ :organizations ], :to => [ :show ]
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
    has_permission_on [ :requests ], :to => :allocate do
      if_permitted_to :manage, :basis
    end
    has_permission_on [ :requests ], :to => :request do
      if_permitted_to :request, :organization
    end
    has_permission_on [ :requests ], :to => :review do
      if_permitted_to :review, :basis
    end
    has_permission_on [ :requests ], :to => :manage do
      if_permitted_to :manage, :basis
    end
    has_permission_on [ :requests ], :to => :manage, :join_by => :and do
      if_permitted_to :request, :organization
      if_attribute :status => is_in { %w( started ) }
    end
    has_permission_on [ :requests ], :to => :approve, :join_by => :and do
      if_permitted_to :request
      if_attribute :status => is_in { %w( started completed ) }
    end
    has_permission_on [ :requests ], :to => :update, :join_by => :and do
      if_permitted_to :review
      if_attribute :status => is_in { %w( accepted ) }
    end
    has_permission_on [ :requests ], :to => :approve, :join_by => :and do
      if_permitted_to :review
      if_attribute :status => is_in { %w( accepted reviewed ) }
    end
    has_permission_on [ :requests ], :to => :unapprove, :join_by => :and do
      if_permitted_to :approve
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
    has_permission_on [ :items ], :to => :update do
      if_permitted_to :update, :request
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

    has_permission_on [ :approvals ], :to => [ :new, :create ] do
      if_permitted_to :approve, :approvable
    end
    has_permission_on [ :approvals ], :to => [ :destroy ], :join_by => :and do
      if_permitted_to :unapprove, :approvable
      if_attribute :user_id => is { user.id }
    end
    has_permission_on [ :approvals ], :to => [ :destroy ] do
      if_permitted_to :manage, :approvable
    end
  end
  role :guest do
    has_permission_on :user_sessions, :to => [ :new, :create ]
  end
end

privileges do
  privilege :request do
    includes :show
  end
  privilege :review do
    includes :show
  end
  privilege :approve do
    includes :show
  end
  privilege :unapprove do
    includes :show
  end
  privilege :manage do
    includes :create, :update, :destroy, :show
  end
  privilege :create do
    includes :new
  end
  privilege :update do
    includes :edit, :move, :do_move
  end
  privilege :show do
    includes :index
  end
end

