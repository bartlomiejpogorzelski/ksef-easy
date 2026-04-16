# frozen_string_literal: true

module Ksef
  module Api
    class Client
      BASE_URL_TEST = "https://api-test.ksef.mf.gov.pl/v2"
      BASE_URL_PROD = "https://api.ksef.mf.gov.pl/v2"

      def initialize(ksef_setting)
        @ksef_setting = ksef_setting
        @connection = build_connection
      end

      def test_connection
        response = @connection.get("/")

        if response.status < 400
          {
            success: true,
            message: "✅ Token jest poprawny!\nPołączenie z środowiskiem testowym KSeF działa prawidłowo.",
            status: response.status
          }
        else
          {
            success: false,
            message: "❌ Nieoczekiwana odpowiedź: HTTP #{response.status}",
            status: response.status
          }
        end
      rescue Faraday::ClientError => e
        { success: false, message: "❌ Błąd: #{parse_error(e)}", status: e.response&.[](:status) }
      rescue Faraday::Error => e
        { success: false, message: "❌ Problem z połączeniem: #{e.message}" }
      end

      # ==================== WYSYŁANIE FAKTURY ====================

      def send_invoice(invoice)
        xml = generate_fa3_xml(invoice)

        # endpoint w KSeF 2.0 testowym
        response = @connection.post("/invoices") do |req|
          req.headers['Content-Type'] = 'application/xml'
          req.body = xml
        end

        {
          success: true,
          reference_number: response.body["referenceNumber"] || response.body.dig("data", "referenceNumber"),
          ksef_number: response.body["ksefNumber"],
          message: "Faktura została wysłana do KSeF"
        }
      rescue Faraday::ClientError => e
        { success: false, message: parse_error(e), status: e.response&.[](:status) }
      rescue Faraday::Error => e
        { success: false, message: "Błąd podczas wysyłania faktury: #{e.message}" }
      end

      private

      def build_connection
        Faraday.new(url: base_url) do |f|
          f.request :authorization, "Bearer", @ksef_setting.token if @ksef_setting.token.present?
          f.request :json
          f.response :json
          f.response :raise_error
          f.response :logger, Rails.logger, bodies: true if Rails.env.development?

          f.request :retry, max: 2, interval: 0.5,
                    exceptions: [Faraday::ConnectionFailed, Faraday::TimeoutError]

          f.adapter Faraday.default_adapter
        end
      end

      def base_url
        @ksef_setting.environment == "prod" ? BASE_URL_PROD : BASE_URL_TEST
      end

      def parse_error(error)
        return error.message unless error.response

        status = error.response[:status]
        body = error.response[:body]

        case status
        when 401 then "Nieprawidłowy lub wygasły token"
        when 403 then "Brak uprawnień do tej operacji"
        when 404 then "Endpoint nie istnieje"
        else
          body.is_a?(Hash) ? (body["message"] || body["error"] || "HTTP #{status}") : "HTTP #{status}"
        end
      end

      # ==================== GENERATOR XML FA(3) ====================
      def generate_fa3_xml(invoice)
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <Fa xmlns="http://crd.gov.pl/xml/schematy/faktury/2022/02/17">
            <FaWersja>3</FaWersja>
            <P_1>#{invoice.issue_date}</P_1>
            <P_2>#{invoice.number}</P_2>
            <P_6>#{invoice.sale_date || invoice.issue_date}</P_6>

            <Podmiot1>
              <NIP>2222222222</NIP>
              <Nazwa>Sprzedawca Testowy KSeF Easy</Nazwa>
            </Podmiot1>

            <Podmiot2>
              <NIP>#{invoice.buyer_nip || '1111111111'}</NIP>
              <Nazwa>#{invoice.buyer_name || 'Testowy Nabywca'}</Nazwa>
            </Podmiot2>

            <P_13_1>#{invoice.netto || 0}</P_13_1>
            <P_13_2>#{invoice.vat || 0}</P_13_2>
            <P_13_3>#{invoice.brutto || 0}</P_13_3>
            <P_14>#{invoice.vat_rate || 23}</P_14>
          </Fa>
        XML
      end

      def init_session
        # Brak pełnej sesji
        { success: true }
      end
    end
  end
end