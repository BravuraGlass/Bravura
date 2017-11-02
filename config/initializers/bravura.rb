class String
  def is_int?
    /\A[-+]?\d+\z/ === self
  end
end

Date.beginning_of_week = :sunday