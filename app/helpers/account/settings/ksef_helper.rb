module Account::Settings::KsefHelper

  def current_ksef_setting
    @current_ksef_setting ||= current_user&.ksef_setting
  end

  def ksef_configured?
    current_ksef_setting&.token_present?
  end

  def ksef_test_mode?
    current_ksef_setting&.environment_test?
  end

  def ksef_production_mode?
    current_ksef_setting&.environment_production?
  end
end