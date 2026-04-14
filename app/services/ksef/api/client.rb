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

      # Test tokenu
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

      # ==================== WYSYŁANIE FAKTUR KSeF 2.0 ====================

      # Krok 1: Inicjalizacja sesji
      def init_session
        response = @connection.post("/sessions") do |req|
          req.body = { "type" => "online" }.to_json
        end

        {
          success: true,
          session_token: response.body["sessionToken"],
          message: "Sesja zainicjowana pomyślnie"
        }
      rescue Faraday::ClientError => e
        { success: false, message: parse_error(e), status: e.response&.[](:status) }
      rescue Faraday::Error => e
        { success: false, message: "Błąd inicjowania sesji: #{e.message}" }
      end

      # Krok 2: Wysyłanie faktury (główna metoda)
      def send_invoice(invoice)
        # Na razie tylko logika przygotowawcza
        xml = generate_xml(invoice)

        # TODO: Pełna wysyłka XML w ramach sesji
        {
          success: false,
          message: "Wysyłanie faktury jeszcze nie zaimplementowane (XML wygenerowany)",
          xml_preview: xml[0..200] + "..."   # tylko podgląd
        }
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

      # Tymczasowy generator XML – na razie prosty placeholder
      def generate_xml(invoice)
        <<~XML
          <Fa xmlns="http://www.w3.org/2001/XMLSchema" xmlns:etd="http://crd.gov.pl/xml/schematy/faktury/2022/02/17">
            <FaWersja>3</FaWersja>
            <P_1>#{invoice.issue_date}</P_1>
            <P_2>#{invoice.number}</P_2>
            <!-- reszta pól będzie dodana w następnym kroku -->
            <Podmiot1>
              <NIP>#{invoice.seller || '2222222222'}</NIP>
            </Podmiot1>
            <Podmiot2>
              <NIP>#{invoice.buyer_nip}</NIP>
              <Nazwa>#{invoice.buyer_name}</Nazwa>
            </Podmiot2>
            <P_13_1>#{invoice.netto}</P_13_1>
            <P_13_2>#{invoice.vat}</P_13_2>
            <P_13_3>#{invoice.brutto}</P_13_3>
          </Fa>
        XML
      end
    end
  end
end