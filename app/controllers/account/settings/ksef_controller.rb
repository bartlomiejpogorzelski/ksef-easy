class Account::Settings::KsefController < ApplicationController
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
      flash.now[:alert] = "Nie udało się zapisać ustawień. Sprawdź błędy poniżej."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def ksef_setting_params
    params.require(:ksef_setting).permit(:nip, :environment, :token)
  end

end