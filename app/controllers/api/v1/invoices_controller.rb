# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::InvoicesController < Api::V1::ApplicationController
    account_load_and_authorize_resource :invoice, through: :team, through_association: :invoices

    # GET /api/v1/teams/:team_id/invoices
    def index
    end

    # GET /api/v1/invoices/:id
    def show
    end

    # POST /api/v1/teams/:team_id/invoices
    def create
      if @invoice.save
        render :show, status: :created, location: [:api, :v1, @invoice]
      else
        render json: @invoice.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/invoices/:id
    def update
      if @invoice.update(invoice_params)
        render :show
      else
        render json: @invoice.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/invoices/:id
    def destroy
      @invoice.destroy
    end

    private

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def invoice_params
        strong_params = params.require(:invoice).permit(
          *permitted_fields,
          :number,
          :issue_date,
          :sale_date,
          :payment_date,
          :netto,
          :vat_rate,
          :vat,
          :brutto,
          :status,
          :buyer_nip,
          :buyer_name,
          :seller,
          :description,
          # 🚅 super scaffolding will insert new fields above this line.
          *permitted_arrays,
          # 🚅 super scaffolding will insert new arrays above this line.
        )

        process_params(strong_params)

        strong_params
      end
    end

    include StrongParameters
  end
else
  class Api::V1::InvoicesController
  end
end
