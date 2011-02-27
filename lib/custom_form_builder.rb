class CustomFormBuilder < Formtastic::SemanticFormBuilder

  # A method that provides read-only access to an attribute
  def read_only_input(method, options = {})
    html_options = options.delete(:input_html)
    html_options[:escape_method] ||= 'h'

    self.label( method, options_for_label(options) ) +
    self.send( html_options[:escape_method], self.object.send(method) )
  end

end

