class Lot < ActiveRecord::Base
  include ActiveModel::Validations

  has_many :users

  validates :number,
            uniqueness: true
  validates :limit,
            presence: true,
            numericality: { greater_than: 0 }
  validates :start_date,
            presence: true
  validates :end_date,
            presence: true
  validate :start_date_must_be_smaller, :dates_cant_overlap



  def self.active_lot
    now = Time.now

    Lot.all.each do |lot|
      if now > lot.start_date && now < lot.end_date
        return lot
      end
    end

    nil
  end

  def is_active?
    self == Lot.active_lot
  end

  def is_full?
    self.users.count >= self.limit
  end

  def self.remove_overdue_users!
    # This event is only gonna have 3 lots
    final_lot = Lot.find(3)
    Lot.all.each do |lot|
      lot.users.each do |user|
        if !user.has_paid_in_time? && DateTime.now > lot.payment_deadline
          user.update_attributes(lot_id: nil, active: false) #Disqualifies the user
          final_lot.increment!(:limit) # increments the :limit by 1
        end
      end
    end
  end

  def to_s
    number
  end

  # Validator methods
  def start_date_must_be_smaller
    errors.add(:start_date, "deve ser menor que a data de término") if self.start_date > self.end_date
  end

  def dates_cant_overlap
    Lot.all.each do |lot|
      unless lot == self
        if start_date > lot.start_date && start_date < lot.end_date
          errors.add(:start_date, "está entre as datas do lote nº #{lot.number}")
        end
        if end_date > lot.start_date && end_date < lot.end_date
          errors.add(:end_date, "está entre as datas do lote nº #{lot.number}")
        end
      end
    end
  end




end
