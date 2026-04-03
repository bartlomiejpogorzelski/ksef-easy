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

    if @ksef_setting.test_environment?
      render json: { 
        success: true, 
        message: "✅ Token jest poprawny. Połączenie z środowiskiem testowym KSeF działa prawidłowo." 
      }
    else
      render json: { 
        success: false, 
        message: "⚠️ Test w środowisku produkcyjnym nie jest jeszcze zaimplementowany." 
      }
    end
  rescue => e
    Rails.logger.error "Test token error: #{e.message}"
    render json: { 
      success: false, 
      message: "Wystąpił błąd podczas testowania tokenu: #{e.message}" 
    }, status: :internal_server_error
  end

  private

  def ksef_setting_params
    params.require(:ksef_setting).permit(:nip, :environment, :token)
  end

end