# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def new_addressable_address_path(addressable)
    case addressable.class.to_s
    when "User"
      new_user_address_path(addressable)
    else
      raise "Class #{addressable.class} not supported"
    end
  end

  def addressable_addresses_url(addressable)
    case addressable.class.to_s
    when "User"
      user_addresses_url(addressable)
    else
      raise "Class #{addressable.class} not supported"
    end
  end

  def addressable_addresses_path(addressable)
    case addressable.class.to_s
    when "User"
      user_addresses_path(addressable)
    else
      raise "Class #{addressable.class} not supported"
    end
  end

  def redcloth(source)
    RedCloth::new(source).to_html
  end

  def render_requestable_detail(requestable)
    render :partial => "#{requestable.class.to_s.underscore.pluralize}/#{requestable.class.to_s.underscore}",
           :object => requestable
  end

  def link_to_unapprove_request(request)
    approval = request.approvals.user_id_equals(current_user.id).first
    if approval && approval.may_destroy?(current_user)
      return link_to 'Unapprove', approval, :confirm => 'Are you sure?', :method => :delete
    end
    ''
  end

  def link_to_request_organization_profiles(request)
    request.organizations.map { |o| link_to "#{o} profile", profile_organization_path(o) }.join " | "
  end
end

