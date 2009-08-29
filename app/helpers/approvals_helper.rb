module ApprovalsHelper
  def render_approvable(approvable)
    type = approvable.class.to_s.underscore
    render :partial => "#{type.pluralize}/#{type}_detail", :object => approvable
  end
end

