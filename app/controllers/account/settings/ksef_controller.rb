class Account::Settings::KsefController < ApplicationController
  helper Account::Settings::KsefHelper
  before_action :authenticate_user!

  def edit
    @ksef_setting = current_user.ksef_setting || current_user.build_ksef_setting
  end

  def update
    @ksef_setting = current_user.ksef_setting || current_user.build_ksef_setting

    @ksef_setting.assign_attributes(ksef_setting_params)

    if @ksef_setting.save
      redirect_to account_settings_ksef_path,
                  notice: "Ustawienia KSeF zostały pomyślnie zapisane."
    else
      Rails.logger.error "KSeF Setting errors: #{@ksef_setting.errors.full_messages}"
      render :edit, status: :unprocessable_entity
    end
  end

  def test_token
    @ksef_setting = current_user.ksef_setting

    if @ksef_setting.nil? || @ksef_setting.token.blank?
      render json: { 
        success: false, 
        message: "Brak tokenu do przetestowania. Najpierw zapisz token." 
      }, status: :unprocessable_entity
      return
    end

    result = ksef_client.test_connection

    render json: result
  rescue => e
    Rails.logger.error "Test token error: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
    render json: { 
      success: false, 
      message: "Wystąpił nieoczekiwany błąd podczas testowania tokenu." 
    }, status: :internal_server_error
  end

  private

  def ksef_client
    @ksef_client ||= Ksef::Api::Client.new(@ksef_setting)
  end

  def ksef_setting_params
    params.require(:ksef_setting).permit(:nip, :environment, :token)
  end
end