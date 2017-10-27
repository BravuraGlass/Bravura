class String
  def is_int?
    /\A[-+]?\d+\z/ === self
  end
end

CHECKIN_BARCODE = "4h30pkkv1b"
CHECKOUT_BARCODE = "6gj6bcc23"