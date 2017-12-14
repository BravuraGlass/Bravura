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

FRACTION_TYPE = [
  "1/2",
  "1/4",
  "1/8",
  "1/16",
  "3/4",
  "3/8",
  "3/16",
  "5/8",
  "5/16",
  "7/8",
  "7/16",
  "9/16",
  "11/16",
  "13/16",
  "15/16"
]