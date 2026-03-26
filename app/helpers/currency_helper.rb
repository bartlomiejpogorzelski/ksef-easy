module CurrencyHelper
  # FOrmat count in zl"
  # Example: 1234.56 → "1 234,56 zł"
  def format_money(amount)
    return "" if amount.nil?

    amount = amount.to_f.round(2)

    formatted = number_with_delimiter(amount, delimiter: " ", separator: ",")

    "#{formatted} zł"
  end

  def format_money_tag(amount)
    content_tag(:span, format_money(amount), class: "font-medium")
  end
end