class Task < ApplicationRecord
  belongs_to :step
  validates :name, length: { in: 0..60 }
  validates :memo, length: { in: 0..400 }
end
