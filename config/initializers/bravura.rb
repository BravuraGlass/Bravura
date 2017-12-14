class String
  def is_int?
    /\A[-+]?\d+\z/ === self
  end
end

Date.beginning_of_week = :sunday

STATUS_DEFAULT = {
  :room => "Active",
  :task => "Measured",
  :material => "In Fabrication"
}

USER_TYPE = {
  :system_administrator => "0",
  :sales_representative => "1",
  :field_worker => "2"
}

EDGE_TYPE = [
  "PL",
  "BV",
  "PL45"
]