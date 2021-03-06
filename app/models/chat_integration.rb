class ChatIntegration < ActiveRecord::Base
  self.abstract_class = true

  belongs_to :project
  validates :project_id, presence: true

  def required_fields_present?
    raise NotImplementedError, "required_fields_present? is not implemented"
  end
end
