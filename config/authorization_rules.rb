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
    has_permission_on [ :requests ], :to => :approve, :join_by => :and do
      if_permitted_to :request
      if_attribute :status => is_in { %w( started completed ) }
    end
    has_permission_on [ :requests ], :to => :approve, :join_by => :and do
      if_permitted_to :review
      if_attribute :status => is_in { %w( accepted reviewed ) }
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
    has_permission_on [ :editions ], :to => :manage, :join_by => :and do
      if_permitted_to :manage, :item
    end
    has_permission_on [ :editions ], :to => :request, :join_by => :and do
      if_permitted_to :request, :item
      if_attribute :perspective => is { Edition::PERSPECTIVES.first }
    end
    has_permission_on [ :editions ], :to => :review, :join_by => :and do
      if_permitted_to :review, :item
    end
    has_permission_on [ :editions ], :to => :manage, :join_by => :and do
      if_permitted_to :review, :item
      if_attribute :item => { :request => { :status => is { 'accepted' } } }
      if_attribute :perspective => is { Edition::PERSPECTIVES.last }
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
  privelege :request do
    includes :show, :index
  end
  privilege :review do
    includes :show, :index
  end
  privelege :approve do
    includes :show
  end
  privilege :manage do
    includes :create, :new, :update, :edit, :destroy, :show, :index
  end
end

