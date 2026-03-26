module ApplicationHelper
  include Helpers::Base

  def current_theme
    :light
  end

  def format_money(amount)
    return "" if amount.nil?

    amount = amount.to_f.round(2)
    formatted = number_with_delimiter(amount, delimiter: " ", separator: ",")
    "#{formatted} zł"
  end
end
