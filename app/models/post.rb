class Post < ApplicationRecord
	has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
  validates :title, presence: true
  validates :cost, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  belongs_to :user

  geocoded_by :address
  after_validation :geocode
 
  def self.search(search)
  	if search
  		search.downcase! # same as search = search.downcase
  		where("lower(title) LIKE ?", "%#{search}%")
  	else
  		all
  	end
  end
end
