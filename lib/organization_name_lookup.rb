module OrganizationNameLookup
  module ClassMethods

  end

  module InstanceMethods

    def organization_name
      organization.name(:last_first) if organization
    end

    def organization_name=(name)
      return self.organization = nil if name.blank?
      attributes = name.to_organization_name_attributes
      self.organization = Organization.where( :last_name => attributes[:last_name],
        :first_name => attributes[:first_name] ).first
    end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

