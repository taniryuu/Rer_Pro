class User < ApplicationRecord
  belongs_to :company
  has_many :leads, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  enum status: { active: 0,
                 inactive: 1,
                 retirement: 2
               }
end
