class SearchesController < ApplicationController
  def search
    data = params[:search]
    @customers = Customer.where("contact_firstname like ? or contact_lastname like ? or address like ?",
    "%#{data}%", "%#{data}%", "%#{data}%")

    # NOTE: Unknown column description
    @jobs = Job.where("notes like ? or address like ?",
    "%#{data}%", "%#{data}%")

    @tasks = Task.where("title like ? or address like ?",
    "%#{data}%", "%#{data}%")

    @fabrication_orders =  FabricationOrder.where("title like ?",
    "%#{data}%")

  end
end
