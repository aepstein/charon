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
          :perspectives => [ Edition::PERSPECTIVES.first ] )
      end
      @unfulfillers[fulfiller] = Factory(fulfiller_type.underscore.to_sym)
    end
    Fulfillment.delete_all
    @fulfillers.each do |fulfiller, requirements|
      requirements.each { |r| Fulfillment.create( :fulfiller => fulfiller, :fulfillable => r.fulfillable ) }
    end
  end

end

