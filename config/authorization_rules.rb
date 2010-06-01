authorization do
  role :admin do
    has_permission_on [ :addresses, :agreements, :approvals, :approvers,
      :bases, :categories, :document_types, :editions, :frameworks, :fulfillments,
      :items, :nodes, :organizations, :permissions, :registration_criterions,
      :registrations, :requests, :roles, :users ], :to => :manage
  end
  role :user do
    has_permission_on [ :agreements, :approvers, :categories, :document_types,
      :frameworks, :fulfillments, :items, :nodes, :organizations, :registration_criterions,
      :roles ], :to => [ :show, :index ]
    has_permission_on [ :users ], :to => [ :edit, :update ] do
      if_attribute :id => is { user.id }
    end
    has_permission_on [ :organizations ], :to => :request do
      if_attribute :memberships => { :user_id => is { user.id }, :active => true, :role => { :permissions => contains { 'request' } } }
    end
    has_permission_on [ :organizations ], :to => :review do
      if_attribute :memberships => { :user_id => is { user.id }, :active => true, :role => { :permissions => contains { 'review' } } }
    end
    has_permission_on [ :organizations ], :to => :manage do
      if_attribute :memberships => { :user_id => is { user.id }, :active => true, :role => { :permissions => contains { 'manage' } } }
    end
    has_permission_on [ :basis ], :to => :request
    has_permission_on [ :basis ], :to => :review do
      if_permitted_to :review, :organization
    end
    has_permission_on [ :basis ], :to => :manage do
      if_permitted_to :manage, :organization
    end
    has_permission_on [ :requests ], :to => :request, :join_by => :and do
      if_permitted_to :request, :organizations
      if_permitted_to :request, :basis
    end
    has_permission_on [ :requests ], :to => :review, :join_by => :and do
      if_permitted_to :review, :basis
    end
    has_permission_on [ :requests ], :to => :manage do
      if_permitted_to :manage, :basis
    end
    has_permission_on [ :requests ], :to => :manage, :join_by => :and do
      if_permitted_to :request
      if_attribute :status => is_in { %w( started ) }
    end
    has_permission_on [ :requests ], :to => [ :show, :index ], :join_by => :and do
      if_permitted_to :request
    end
  end
  role :guest do
    has_permission_on :user_sessions, :to => [ :new, :create ]
  end
end

privileges do
  privilege :manage do
    includes :create, :new, :update, :edit, :destroy, :show, :index
  end
end

