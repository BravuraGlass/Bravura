#*config/initializers/carrier_wave.rb*

require 'carrierwave/orm/activerecord'

CarrierWave.configure do |config|
  config.ignore_integrity_errors = false
  config.ignore_processing_errors = false
  config.ignore_download_errors = false
end
