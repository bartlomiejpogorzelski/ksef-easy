module ApplicationHelper
  include Helpers::Base
  include CurrencyHelper

  def current_theme
    :light
  end
end
