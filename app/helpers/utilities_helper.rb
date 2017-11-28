module UtilitiesHelper
  def megabyte(thefile)
    size = '%.2f' % (File.size(Rails.root+"tmp/backup/"+thefile).to_f / 2**20)
    return "#{size} mb"
  end  
end
