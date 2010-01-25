class UserSession < Authlogic::Session::Base
  def gettext(str); GetText._(str); end
end

