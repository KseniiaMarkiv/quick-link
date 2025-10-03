class Supplier < ApplicationRecord
  # Force the two flags to behave like a toggle pair
  before_validation :normalize_status_flags

  # Guard rail: never allow both to be true
  validate :active_inactive_mutex
  validates :sku, presence: true

  # Convenience (used in views if you want)
  def active?
    !!active
  end

  private

  # Cast inputs (from forms or Excel) and make the pair mutually exclusive.
  def normalize_status_flags
    # Cast anything like "1"/"0", "y"/"n", true/false, etc.
    bool = ActiveRecord::Type::Boolean.new
    self.active   = bool.cast(active)
    self.inactive = bool.cast(inactive)

    # If the user set Active to true, force Inactive to false.
    if will_save_change_to_attribute?(:active) && active
      self.inactive = false
    end

    # If the user set Inactive to true, force Active to false.
    if will_save_change_to_attribute?(:inactive) && inactive
      self.active = false
    end

    # Safety net for bulk imports or odd cases where both arrive true:
    if active && inactive
      # Prefer "active" and zero out inactive (change to your preference)
      self.inactive = false
    end
  end

  def active_inactive_mutex
    errors.add(:base, "Choose either Active or Inactive, not both.") if active && inactive
  end
end
