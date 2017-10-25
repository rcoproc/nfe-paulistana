module NfePaulistana
  class Response
    RETURN_ROOT = {
      recepcionar_lote_rps: :enviar_lote_rps,
      consulta_n_fe: :consulta,
      consulta_n_fe_emitidas: :consulta,
      consulta_n_fe_recebidas: :consulta,
      consultar_lote_rps: :consultar_lote_rps,
      cancelamento_n_fe: :cancelar_nfse,
      consulta_informacoes_lote: :informacoes_lote,
    }
    def initialize(options = {})
      @options = options
    end

    def xml
      @options[:xml]
    end

    def nfe_method
      @options[:method]
    end

    def retorno
      Nori.new(:convert_tags_to => lambda { |tag| tag.snakecase.to_sym }).parse(xml)[((RETURN_ROOT[@options[:method]] || @options[:method]).to_s + "_resposta").to_sym]
    end

    def success?
      !!retorno[:cabecalho][:sucesso]
    end

    def errors
      return unless !success?
      retorno[:alerta] || retorno[:erro]
    end
  end
end
