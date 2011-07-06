module SpecRequirementScenarios

  def setup_requirements_scenario
    # Eliminate other requirements
    Requirement.delete_all
    # Set up a requirement of each possible type and actors that fulfill or don't fulfill each
    @framework = Factory(:framework)
    @fulfillers, @unfulfillers = Hash.new, Hash.new
    Fulfillment::FULFILLABLE_TYPES.each do |fulfiller_type, fulfillable_types|
      fulfiller = Factory(fulfiller_type.underscore.to_sym)
      @fulfillers[fulfiller] = fulfillable_types.map do |type|
        Factory( :requirement, :framework => @framework, :fulfillable => Factory(type.underscore.to_sym),
          :perspectives => [ FundEdition::PERSPECTIVES.first ] )
      end
      @unfulfillers[fulfiller] = Factory(fulfiller_type.underscore.to_sym)
    end
    Fulfillment.delete_all
    @fulfillers.each do |fulfiller, requirements|
      requirements.each { |r| Fulfillment.create( :fulfiller => fulfiller, :fulfillable => r.fulfillable ) }
    end
  end

  def setup_requirements_role_limited_scenario
    fulfiller_type = Fulfillment::FULFILLABLE_TYPES.keys.first
    fulfillable_type = Fulfillment::FULFILLABLE_TYPES[ fulfiller_type ].first
    @limited_fulfillable = Factory(fulfillable_type.underscore.to_sym)
    @unlimited_fulfillable = Factory(fulfillable_type.underscore.to_sym)
    @limited_role = Factory(:role)
    @unlimited_role = Factory(:role)
    @framework = Factory(:framework)
    @limited_requirement = Factory(:requirement, :fulfillable => @limited_fulfillable,
      :framework => @framework, :perspectives => [ FundEdition::PERSPECTIVES.first ],
      :role => @limited_role )
    @unlimited_requirement = Factory(:requirement, :fulfillable => @unlimited_fulfillable,
      :framework => @framework, :perspectives => [ FundEdition::PERSPECTIVES.first ] )
    @all = Factory(fulfiller_type.underscore.to_sym)
    Factory(:fulfillment, :fulfiller => @all, :fulfillable => @limited_fulfillable)
    Factory(:fulfillment, :fulfiller => @all, :fulfillable => @unlimited_fulfillable)
    @limited = Factory(fulfiller_type.underscore.to_sym)
    Factory(:fulfillment, :fulfiller => @limited, :fulfillable => @limited_fulfillable)
    @unlimited = Factory(fulfiller_type.underscore.to_sym)
    Factory(:fulfillment, :fulfiller => @unlimited, :fulfillable => @unlimited_fulfillable)
    @no = Factory(fulfiller_type.underscore.to_sym)
  end

end

