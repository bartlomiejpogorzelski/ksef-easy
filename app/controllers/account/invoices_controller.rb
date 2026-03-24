class Account::InvoicesController < Account::ApplicationController
  account_load_and_authorize_resource :invoice, through: :team, through_association: :invoices

  # GET /account/teams/:team_id/invoices
  # GET /account/teams/:team_id/invoices.json
  def index
    delegate_json_to_api
  end

  # GET /account/invoices/:id
  # GET /account/invoices/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/teams/:team_id/invoices/new
  def new
  end

  # GET /account/invoices/:id/edit
  def edit
  end

  # POST /account/teams/:team_id/invoices
  # POST /account/teams/:team_id/invoices.json
  def create
    respond_to do |format|
      if @invoice.save
        format.html { redirect_to [:account, @invoice], notice: I18n.t("invoices.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @invoice] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/invoices/:id
  # PATCH/PUT /account/invoices/:id.json
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html { redirect_to [:account, @invoice], notice: I18n.t("invoices.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @invoice] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/invoices/:id
  # DELETE /account/invoices/:id.json
  def destroy
    @invoice.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @team, :invoices], notice: I18n.t("invoices.notifications.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  if defined?(Api::V1::ApplicationController)
    include strong_parameters_from_api
  end

  def process_params(strong_params)
    assign_date(strong_params, :issue_date)
    assign_date(strong_params, :sale_date)
    assign_date(strong_params, :payment_date)

    strong_params[:document] = params[:invoice][:document] if params[:invoice][:document]

    # 🚅 super scaffolding will insert processing for new fields above this line.
  end
end
