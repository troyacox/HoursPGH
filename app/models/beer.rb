class Beer < ActiveRecord::Base
  scope :name_like, -> (name) { where("name ilike ?", name)}

  belongs_to :venue

 before_save :default_values
  def default_values
    self.beer_status ||= 2
  end
end
