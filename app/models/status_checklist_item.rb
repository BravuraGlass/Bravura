class StatusChecklistItem < ApplicationRecord
  include AuditableModel

  belongs_to :status, dependent: :destroy


  def as_json(options)
      super(
          only: [:title],
          include: {
            status: {
              only: [:name],
            }
          }
      )
  end

end
