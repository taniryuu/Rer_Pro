class Company < ApplicationRecord
  enum status: { active: 0, 
                 inactive: 1 
               }
  
  validates :name, presence: true, 
                   uniqueness: true
  validates :admin, inclusion: { in: [true, false] }
  validates :status, presence: true,
                     numericality: { greater_than_or_equal_to: 0,
                                     less_than_or_equal_to: 1
                                   }
end
