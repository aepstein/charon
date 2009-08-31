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
    render :partial => "#{requestable.class.to_s.underscore.pluralize}/#{requestable.class.to_s.underscore}_detail",
           :object => requestable
  end
end

