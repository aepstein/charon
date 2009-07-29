module GlobalModelAuthorization

  def may_create?(user)
    may_admin? user
  end

  def may_update?(user)
    may_admin? user
  end

  def may_destroy?(user)
    may_admin? user
  end

  def may_see?(user)
    true
  end

private

  def may_admin?(user)
    return false if user.nil?
    return true if user.admin?
    false
  end

end

