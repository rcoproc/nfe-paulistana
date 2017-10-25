require 'savon'

module NfePaulistana
  class Gateway

    METHODS = {
      envio_rps: "EnvioRPSRequest",
      envio_lote_rps: "RecepecionarLoteRPSRequest",
      recepcionar_lote_rps: "RecepcionarLoteRPSRequest",
      cancelar_nfse: "CancelarNfseRequest",
      consulta_cnpj: "ConsultaCNPJRequest",
      consulta_n_fe: "ConsultaNFeRequest",
      consulta_n_fe_recebidas: "ConsultaNFeRecebidasRequest",
      consulta_n_fe_emitidas: "ConsultaNFeEmitidasRequest",
      consulta_lote: "ConsultaLoteRequest",
      consulta_informacoes_lote: "ConsultaInformacoesLoteRequest"
    }

    def initialize(options = {})
      @options = {
        wsdl: 'http://issonline.pnl.mg.gov.br/nfe/snissdigitalsvc.dll/wsdl/IuWebServiceIssDigital',
        endpoint: 'http://issonline.pnl.mg.gov.br/nfe/snissdigitalsvc.dll/soap/IuWebServiceIssDigital',
        log: true
      }.merge(options)

	
    end

    def envio_rps(data = {})
      request(:envio_rps, data)
    end

    def envio_lote_rps(data = {})
      request(:recepcionar_lote_rps, data)
    end

    def teste_envio_lote_rps(data = {})
      request(:recepcionar_lote_rps, data)
    end

    def cancelamento_nfe(data = {})
      request(:cancelar_nfse, data)
    end

    def consulta_nfe(data = {})
      request(:consulta_n_fe, data)
    end

    def consulta_nfe_recebidas(data = {})
      request(:consulta_n_fe_recebidas, data)
    end

    def consulta_nfe_emitidas(data = {})
      request(:consulta_n_fe_emitidas, data)
    end

    def consulta_lote(data = {})
      request(:consultar_lote_rps, data)
    end

    def consulta_informacoes_lote(data = {})
      request(:consulta_informacoes_lote, data)
    end

    def consulta_cnpj(data = {})
      request(:consulta_cnpj, data)
    end

    private

    def certificate
      OpenSSL::PKCS12.new(File.read(@options[:ssl_cert_p12_path]), @options[:ssl_cert_pass])
    end

    def request(method, data = {})
      certificado = certificate rescue nil
      client = get_client
      message = XmlBuilder.new.xml_for(method, data)
      response = client.call(method, message: message)
      method_response = (method.to_s + "_response").to_sym
      Response.new(xml: response.hash[:envelope][:body][method_response][:return], method: method)
    rescue Savon::Error => error
    end

    def get_client
      #Savon.client(env_namespace: :soap,
      Savon.client(env_namespace: :soap, 
                   ssl_verify_mode: :none, 
                   log: true,
                   log_level: :debug,
                   pretty_print_xml: true,
                   wsdl: @options[:wsdl], 
                   endpoint: @options[:endpoint],
                   open_timeout: 300,
                   read_timeout: 300)
                   
    end
  end
end
