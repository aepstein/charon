class Fulfillment < ActiveRecord::Base
  FULFILLABLE_TYPES = {
    'User' => %w( Agreement UserStatusCriterion ),
    'Organization' => %w( RegistrationCriterion )
  }

  attr_accessible :fulfiller, :fulfillable

  belongs_to :fulfiller, :polymorphic => true
  belongs_to :fulfillable, :polymorphic => true

  validates :fulfiller_type, :inclusion => { :in => FULFILLABLE_TYPES.keys }
  validates :fulfiller, :presence => true
  validates :fulfillable, :presence => true
  validates :fulfillable_id,
    :uniqueness => { :scope => [ :fulfillable_type, :fulfiller_id, :fulfiller_type ] }
  validate :fulfillable_must_be_for_fulfiller

  protected

  def fulfillable_must_be_for_fulfiller
    return unless fulfiller && fulfillable
    unless fulfillable.class.fulfiller_type == fulfiller_type
      errors.add :fulfillable_type, "not allowed for #{fulfiller_type}"
    end
  end

end

