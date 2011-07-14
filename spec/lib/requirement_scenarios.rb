module SpecRequirementScenarios

  def setup_requirements_scenario
    # Eliminate other requirements
    Requirement.delete_all
    # Set up a requirement of each possible type and actors that fulfill or don't fulfill each
    @framework = create(:framework)
    @fulfillers, @unfulfillers = Hash.new, Hash.new
    Fulfillment::FULFILLABLE_TYPES.each do |fulfiller_type, fulfillable_types|
      fulfiller = create(fulfiller_type.underscore.to_sym)
      @fulfillers[fulfiller] = fulfillable_types.map do |type|
        create( :requirement, :framework => @framework, :fulfillable => create(type.underscore.to_sym),
          :perspectives => [ FundEdition::PERSPECTIVES.first ] )
      end
      @unfulfillers[fulfiller] = create(fulfiller_type.underscore.to_sym)
    end
    Fulfillment.delete_all
    @fulfillers.each do |fulfiller, requirements|
      requirements.each { |r| Fulfillment.create( :fulfiller => fulfiller, :fulfillable => r.fulfillable ) }
    end
  end

  def setup_requirements_role_limited_scenario
    fulfiller_type = Fulfillment::FULFILLABLE_TYPES.keys.first
    fulfillable_type = Fulfillment::FULFILLABLE_TYPES[ fulfiller_type ].first
    @limited_fulfillable = create(fulfillable_type.underscore.to_sym)
    @unlimited_fulfillable = create(fulfillable_type.underscore.to_sym)
    @limited_role = create(:role)
    @unlimited_role = create(:role)
    @framework = create(:framework)
    @limited_requirement = create(:requirement, :fulfillable => @limited_fulfillable,
      :framework => @framework, :perspectives => [ FundEdition::PERSPECTIVES.first ],
      :role => @limited_role )
    @unlimited_requirement = create(:requirement, :fulfillable => @unlimited_fulfillable,
      :framework => @framework, :perspectives => [ FundEdition::PERSPECTIVES.first ] )
    @all = create(fulfiller_type.underscore.to_sym)
    create(:fulfillment, :fulfiller => @all, :fulfillable => @limited_fulfillable)
    create(:fulfillment, :fulfiller => @all, :fulfillable => @unlimited_fulfillable)
    @limited = create(fulfiller_type.underscore.to_sym)
    create(:fulfillment, :fulfiller => @limited, :fulfillable => @limited_fulfillable)
    @unlimited = create(fulfiller_type.underscore.to_sym)
    create(:fulfillment, :fulfiller => @unlimited, :fulfillable => @unlimited_fulfillable)
    @no = create(fulfiller_type.underscore.to_sym)
  end

end

