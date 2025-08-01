require 'cuid'

class Post < ApplicationRecord

  before_create :set_cuid_as_id

  validates :title, :author, :body, presence: true

  has_many :comments, dependent: :destroy

  private

  def set_cuid_as_id
    self.id = Cuid.generate unless self.id.present?
  end
end