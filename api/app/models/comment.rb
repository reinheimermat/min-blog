require 'cuid'

class Comment < ApplicationRecord

  validates :author, :body, presence: true

  before_create :set_cuid_as_id

  belongs_to :post

  private

  def set_cuid_as_id
    self.id = Cuid.generate unless self.id.present?
  end
end
