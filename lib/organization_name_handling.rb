module OrganizationNameHandling
  module ClassMethods
  end

  module InstanceMethods
    def to_organization_name_attributes
      names = split(',')
      if self =~ /,$/
        { :first_name => '', :last_name => names.join(',') }
      elsif names.size > 1
        { :first_name => names.pop.strip, :last_name => names.join(',') }
      else
        { :first_name => '', :last_name => names.pop }
      end
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

String.send(:include, OrganizationNameHandling)

