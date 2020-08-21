class Company < ApplicationRecord
  enum status: { active: 0, 
                 inactive: 1 
               }
  
  validates :name, presence: true, 
                   uniqueness: true
  validates :admin, inclusion: { in: [true, false] }
  validates :status, presence: true
end
