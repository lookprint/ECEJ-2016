class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  belongs_to :lot
  has_one :address
  has_many :special_needs

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100#" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  # Returns false unless the user has updated all of his information
  def is_completed?
    return false unless self.completed
    true
  end

  # Lists
  def self.disqualified_list
    User.where(active: false)    
  end
  def self.waiting_list
    User.where(lot_id: nil, active: nil)
  end

  # Insert users into groups
  def insert_into_disqualified_list!
    self.update_attribute(:active, false)
  end
  def insert_into_waiting_list!
    self.update_attribute(:lot_id, nil)
  end
  def insert_into_active_lot!
      self.update_attribute(:lot_id, Lot.active_lot)  
  end

  # METHODS USED IN THE SCHEDULED TASK
  # Call this method in the scheduled task
  def self.organize_lots!
    User.insert_inactive_users_into_disqualified_lot! 
    if Lot.active_lot.users.count <= Lot.active_lot.limit
      self.insert_into_active_lot!
    else
      self.insert_into_waiting_list
    end
  end

  # checks if the user has confirmed within 15 days.
  def has_passed_15_days_since_creation?
    (Time.now - self.created_at) > 15.days
  end

  # Method to inactivate users who hasn't qualified in 15 days.
  def self.insert_inactive_users_into_disqualified_lot!
    User.waiting_list.each do |user|
      unless user.is_completed? && user.has_paid?
        if user.has_passed_15_days_since_creation?
          user.insert_into_disqualified_list!
          Rails.logger.info "--- RETIRADO POR INATIVIDADE: #{user.name}"
        end
      end
    end
  end

end
