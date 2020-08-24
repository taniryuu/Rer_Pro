class Company < ApplicationRecord
  has_many :users, dependent: :destroy
  enum status: { active: 0, 
                 inactive: 1 
               }
  
  validates :name, presence: true, 
                   uniqueness: true
  validates :admin, inclusion: { in: [true, false] }
  validates :status, presence: true
end