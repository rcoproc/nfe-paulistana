module NfePaulistana
  class XmlBuilder

    METHODS = {
      envio_rps: "PedidoEnvioRPS",
      envio_lote_rps: "EnviarLoteRPSEnvio",                 # Ok PNL
      recepcionar_lote_rps: "EnviarLoteRpsEnvio",
      cancelar_nfse: "CancelarNfse",
      consulta_n_fe: "ConsultaNse",
      consulta_n_fe_recebidas: "PedidoConsultaNFePeriodo",
      consulta_n_fe_emitidas: "PedidoConsultaNFePeriodo",
      consultar_lote_rps: "ConsultarLoteRps",
      consulta_informacoes_lote: "PedidoInformacoesLote",
      consulta_cnpj: "PedidoConsultaCNPJ"
    }

    DEFAULT_DATA = {
      :cpf_remetente => '',
      :cnpj_remetente => '',
      :inscricao_prestador => '',
      :senha => '',
      :frase_secreta => '',
      :protocolo => '',
      :serie_rps => '',
      :numero_rps => '',
      :tipo_rps => '',
      :data_emissao => '',
      :competencia => '', 
      :status_rps => '',
      :tributacao_rps => '',
      :valor_servicos => '0',
      :valor_deducoes => '0',
      :valor_pis => '0',
      :valor_cofins => '0',
      :valor_inss => '0',
      :valor_iss => '0',
      :valor_ir => '0',
      :valor_csll => '0',
      :codigo_servico => '0',
      :codigo_cnae => '0', 
      :codigo_tributacao_municipio => '0',
      :exigibilidade_iss => '',
      :optante_simples_nacional => '', 
      :incentivo_fiscal => '', 
      :producao => '',
      :aliquota_servicos => '0',
      :iss_retido => false,
      :cpf_tomador => '',
      :cnpj_tomador => '',
      :iss_retido_intermediario => false,
      :cpf_intermediario => '',
      :cnpj_intermediario => '',
      :im_tomador => '',
      :ie_tomador => '',
      :im_intermediario => '',
      :razao_tomador => '',
      :tp_logradouro => '',
      :endereco => '',
      :logradouro => '',
      :nr_endereco => '',
      :compl_endereco => '',
      :bairro => '',
      :codigo_municipio_tomador => '', 
      :cidade => '',
      :uf => '',
      :cep => '',
      :codigo_pais => '1058',
      :email_tomador => '',
      :email_intermediario => '',
      :discriminacao => '',
      :wsdl => 'https://nfe.prefeitura.sp.gov.br/ws/lotenfe.asmx?wsdl'
    }

    def xml_for(method,data)
      data = DEFAULT_DATA.merge(data)
      File.open("#{method.to_s}.xml", 'w') do |file|
        file.write(xml(method, data))
      end
      #("<VersaoSchema>1</VersaoSchema><MensagemXML>" + assinar(xml(method, data)).gsub("&","&amp;").gsub(">","&gt;").gsub("<","&lt;").gsub("\"","&quot;").gsub("'","&apos;") + "</MensagemXML>").gsub(/\n/,'')
      #("<Value>" + assinar(xml(method, data)) + "</Value>")
      (assinar(xml(method, data)))
    end

    private
    
    def xml(method, data)
      builder = Nokogiri::XML::Builder.new do |xml|
        if method == :recepcionar_lote_rps
          xml.Value {
            xml.send(METHODS[method], "xmlns" => "http://www.abrasf.org.br/nfse.xsd" ) {
              xml.LoteRps( :Id => data[:numero_lote] , "versao" => "2.01") {
                xml.NumeroLote data[:numero_lote]
                xml.CpfCnpj {
                  xml.Cpf data[:cpf_remetente] unless data[:cpf_remetente].blank?
                  xml.Cnpj data[:cnpj_remetente] unless data[:cnpj_remetente].blank?
                }
                send("add_#{method}_cabecalho_data_to_xml", xml, data)
                send("add_#{method}_data_to_xml", xml, data)
              }
            }
          }
        else
          xml.Value {
            xml.send(METHODS[method]){
              send("add_#{method}_cabecalho_data_to_xml", xml, data)
              send("add_#{method}_data_to_xml", xml, data)
            }
          }
        end
      end
      Nokogiri::XML( builder.to_xml( :save_with => Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION ) )
      #builder.to_xml( :save_with => Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION ) 
    end

    def add_cancelar_nfse_cabecalho_data_to_xml(xml, data)
      xml.Numero data[:numero_nfse]
    end

    def add_envio_rps_cabecalho_data_to_xml(xml, data)
    end

    def add_recepcionar_lote_rps_cabecalho_data_to_xml(xml, data)
      add_lote_cabecalho_data_to_xml(xml, data)
    end

    def add_recepcionar_lote_rps_cabecalho_data_to_xml(xml, data)
      add_lote_cabecalho_data_to_xml(xml, data)
    end

    def add_lote_cabecalho_data_to_xml(xml, data)
      xml.InscricaoMunicipal data[:inscricao_prestador] if !data[:inscricao_prestador].blank?
      xml.QuantidadeRps data[:qtd_rps]
    end

    def add_consulta_cnpj_cabecalho_data_to_xml(xml, data)
    end

    def add_consulta_n_fe_cabecalho_data_to_xml(xml, data)
    end

    def add_consulta_n_fe_recebidas_cabecalho_data_to_xml(xml,data)
      add_consulta_n_fe_periodo_cabecalho_data_to_xml(xml, data)
    end

    def add_consulta_n_fe_emitidas_cabecalho_data_to_xml(xml,data)
      add_consulta_n_fe_periodo_cabecalho_data_to_xml(xml, data)
    end

    def add_consulta_n_fe_periodo_cabecalho_data_to_xml(xml, data)
      unless (data[:cpf].blank? and data[:cnpj].blank?)
        xml.CpfCnpj {
          xml.Cpf data[:cpf] unless data[:cpf].blank?
          xml.Cnpj data[:cnpj] unless data[:cnpj].blank?
        }
      end
      xml.InscricaoMunicipal data[:inscricao_prestador] if !data[:inscricao_prestador].blank?
      xml.dtInicio data[:data_inicio]
      xml.dtFim data[:data_fim]
      xml.NumeroPagina data[:pagina] || 1
    end

    def add_consultar_lote_rps_cabecalho_data_to_xml(xml, data)
      xml.Protocolo data[:protocolo]
    end

    def add_consulta_informacoes_lote_cabecalho_data_to_xml(xml, data)
      xml.NumeroLote data[:numero_lote]
    end

    def add_consulta_n_fe_recebidas_data_to_xml(xml, data)
    end

    def add_consulta_n_fe_emitidas_data_to_xml(xml, data)
    end

    def add_consulta_n_fe_data_to_xml(xml, data)
      xml.Detalhe(:xmlns => "") {
        add_chave_rps_to_xml(xml, data) if !data[:numero_rps].blank? and !data[:serie_rps].blank?
        add_chave_nfe_to_xml(xml, data) if data[:numero_nfe]
      }
    end

    def add_consulta_cnpj_data_to_xml(xml, data)
      xml.CNPJContribuinte(:xmlns => "") {
        xml.CNPJ data[:cnpj_contribuinte]
      }
    end

    def add_cancelar_nfse_data_to_xml(xml, data)
      xml.CpfCnpj {
        xml.Cnpj data[:cnpj_remetente]
      }
      xml.InscricaoPrestador data[:inscricao_prestador]
    end

    def add_envio_rps_data_to_xml(xml, data)
      add_rps_to_xml(xml, data)
    end

    def add_envio_lote_rps_data_to_xml(xml, data)
      add_lote_rps_data_to_xml(xml, data)
    end

    def add_recepcionar_lote_rps_data_to_xml(xml, data)
      add_lote_rps_data_to_xml(xml, data)
    end

    def add_lote_rps_data_to_xml(xml, data)
      data[:lote_rps].each do |rps|
        add_rps_to_xml(xml, rps)
      end
    end

    def add_consultar_lote_rps_data_to_xml(xml, data)
      xml.Prestador {
        xml.CpfCnpj {
          xml.Cnpj data[:cnpj_remetente]
        }
        xml.Senha data[:senha]
        xml.FraseSecreta data[:frase_secreta]
      }
    end

    def add_consulta_informacoes_lote_data_to_xml(xml, data)
    end

    def add_chave_nfe_to_xml(xml, data)
      xml.ChaveNFe {
        xml.InscricaoPrestador data[:inscricao_prestador]
        xml.NumeroNFe data[:numero_nfe]
      }
    end

    def add_chave_rps_to_xml(xml, data)
      xml.Rps( "Id"=> data[:numero_rps] ) {
        xml.IdentificacaoRps { 
          xml.Numero data[:numero_rps] unless data[:numero_rps].blank?
          xml.Serie data[:serie_rps] unless data[:serie_rps].blank?
          xml.Tipo data[:tipo_rps] unless data[:tipo_rps].blank?
        }
        xml.DataEmissao data[:data_emissao]
        xml.Status data[:status_rps]
      }
    end

    def add_rps_to_xml(xml, data)
      data = DEFAULT_DATA.merge(data)
      xml.ListaRps {
        # xml.Assinatura assinatura_envio_rps(data)
        xml.Rps {
          xml.InfDeclaracaoPrestacaoServico( :xmlns => "http://www.abrasf.org.br/nfse.xsd", :Id => data[:numero_rps]) {
            add_chave_rps_to_xml(xml, data)
            xml.Competencia data[:competencia]
            xml.Servico {
              xml.Valores {
                xml.ValorServicos data[:valor_servicos]
                xml.ValorDeducoes data[:valor_deducoes] 
                xml.ValorPis data[:valor_pis] if data[:valor_pis] != '0'
                xml.ValorCofins data[:valor_cofins] if data[:valor_cofins] != '0'
                xml.ValorInss data[:valor_inss] if data[:valor_inss] != '0'
                xml.ValorIr data[:valor_ir] if data[:valor_ir] != '0'
                xml.ValorCsll data[:valor_csll] if data[:valor_csll] != '0'
                xml.ValorIss data[:valor_iss] if data[:valor_iss] != '0'
                xml.Aliquota data[:aliquota_servicos] if data[:aliquota_servicos] != '0'
              }

              xml.IssRetido data[:iss_retido]
              xml.ItemListaServico data[:item_lista_servico]
              xml.CodigoCnae data[:codigo_cnae]
              xml.CodigoTributacaoMunicipio data[:codigo_tributacao_municipio]
              xml.Discriminacao data[:discriminacao]
              xml.CodigoMunicipio data[:codigo_municipio_prestador]
              xml.CodigoPais data[:codigo_pais]
              xml.ExigibilidadeISS data[:exigibilidade_iss]
            }

            xml.Prestador {
              xml.CpfCnpj { 
                xml.Cnpj data[:cnpj_remetente] unless data[:cnpj_remetente].blank?
              }
              xml.InscricaoMunicipal data[:inscricao_prestador] 
              xml.Senha data[:senha]
              xml.FraseSecreta data[:frase_secreta]
            }

            xml.Tomador {
              xml.IdentificacaoTomador{
                unless (data[:cpf_tomador].blank? and data[:cnpj_tomador].blank?)
                  xml.CpfCnpj { 
                    xml.Cpf data[:cpf_tomador] unless data[:cpf_tomador].blank?
                    xml.Cnpj data[:cnpj_tomador] unless data[:cnpj_tomador].blank?
                  }
                end
              }
              xml.InscricaoMunicipalTomador data[:im_tomador] unless data[:im_tomador].blank?
              xml.InscricaoEstadualTomador data[:ie_tomador] unless data[:ie_tomador].blank?
              xml.RazaoSocial data[:razao_tomador] unless data[:razao_tomador].blank?
              unless (data[:endereco].blank? and data[:nr_endereco] and data[:compl_endereco])
                xml.Endereco {
                  xml.Endereco data[:endereco]
                  xml.Numero data[:nr_endereco]
                  xml.Complemento data[:compl_endereco] unless data[:compl_endereco].blank?
                  xml.Bairro data[:bairro] unless data[:bairro].blank?
                  xml.CodigoMunicipio data[:codigo_municipio_tomador] unless data[:codigo_municipio_tomador].blank?
                  xml.Cidade data[:cidade] unless data[:cidade].blank?
                  xml.Uf data[:uf] unless data[:uf].blank?
                  xml.CodigoPais data[:codigo_pais] unless data[:codigo_pais].blank?
                  xml.Cep data[:cep] unless data[:cep].blank?
                }
              end
              xml.Contato {
                xml.Telefone data[:telefone_tomador] unless data[:telefone_tomador].blank?
                xml.Email data[:email_tomador]
              }
            }
            xml.RegimeEspecialTributacao data[:regime_especial_tributacao]
            xml.OptanteSimplesNacional data[:optante_simples_nacional]
            xml.IncentivoFiscal data[:incentivo_fiscal]

            xml.Producao data[:producao]
          }
        }
=begin
        unless (data[:cpf_intermediario].blank? and data[:cnpj_intermediario].blank?)
          xml.CPFCNPJIntermediario { 
            xml.CPF data[:cpf_intermediario] unless data[:cpf_intermediario].blank?
            xml.CNPJ data[:cnpj_intermediario] unless data[:cnpj_intermediario].blank?
          }
          xml.InscricaoMunicipalIntermediario data[:im_intermediario] unless data[:im_intermediario].blank?
          xml.ISSRetidoIntermediario data[:iss_retido_intermediario]
          xml.EmailIntermediario data[:email_intermediario]
        end
=end
      }
    end

    def assinar(xml)

      xml = Nokogiri::XML(xml.to_s, &:noblanks)

      ## 1. Digest Hash for all XML
      #xml_canon = xml.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
      #xml_digest = Base64.encode64(OpenSSL::Digest::SHA1.digest(xml_canon)).strip

      ## 2. Add Signature Node
      #signature = xml.xpath("//ds:Signature", "ds" => "http://www.w3.org/2000/09/xmldsig#").first
      #unless signature
      #  signature = Nokogiri::XML::Node.new('Signature', xml)
      #  signature.default_namespace = 'http://www.w3.org/2000/09/xmldsig#'
      #  xml.root().add_child(signature)
      #end

      ## 3. Add Elements to Signature Node
      
      ## 3.1 Create Signature Info
      #signature_info = Nokogiri::XML::Node.new('SignedInfo', xml)

      ## 3.2 Add CanonicalizationMethod
      #child_node = Nokogiri::XML::Node.new('CanonicalizationMethod', xml)
      #child_node['Algorithm'] = 'http://www.w3.org/2001/10/xml-exc-c14n#'
      #signature_info.add_child child_node

      ## 3.3 Add SignatureMethod
      #child_node = Nokogiri::XML::Node.new('SignatureMethod', xml)
      #child_node['Algorithm'] = 'http://www.w3.org/2000/09/xmldsig#rsa-sha1'
      #signature_info.add_child child_node

      ## 3.4 Create Reference
      #reference = Nokogiri::XML::Node.new('Reference', xml)
      #reference['URI'] = ''

      ## 3.5 Add Transforms
      #transforms = Nokogiri::XML::Node.new('Transforms', xml)

      #child_node  = Nokogiri::XML::Node.new('Transform', xml)
      #child_node['Algorithm'] = 'http://www.w3.org/2000/09/xmldsig#enveloped-signature'
      #transforms.add_child child_node

      #child_node  = Nokogiri::XML::Node.new('Transform', xml)
      #child_node['Algorithm'] = 'http://www.w3.org/TR/2001/REC-xml-c14n-20010315'
      #transforms.add_child child_node

      #reference.add_child transforms

      ## 3.6 Add Digest
      #child_node  = Nokogiri::XML::Node.new('DigestMethod', xml)
      #child_node['Algorithm'] = 'http://www.w3.org/2000/09/xmldsig#sha1'
      #reference.add_child child_node
      
      ## 3.6 Add DigestValue
      #child_node  = Nokogiri::XML::Node.new('DigestValue', xml)
      #child_node.content = xml_digest
      #reference.add_child child_node

      ## 3.7 Add Reference and Signature Info
      #signature_info.add_child reference
      #signature.add_child signature_info

      ## 4 Sign Signature
      #sign_canon = signature_info.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
      #signature_hash = certificado.key.sign(OpenSSL::Digest::SHA1.new, sign_canon)
      #signature_value = Base64.encode64( signature_hash ).gsub("\n", '')

      ## 4.1 Add SignatureValue
      #child_node = Nokogiri::XML::Node.new('SignatureValue', xml)
      #child_node.content = signature_value
      #signature.add_child child_node

      ## 5 Create KeyInfo
      #key_info = Nokogiri::XML::Node.new('KeyInfo', xml)
      
      ## 5.1 Add X509 Data and Certificate
      #x509_data = Nokogiri::XML::Node.new('X509Data', xml)
      #x509_certificate = Nokogiri::XML::Node.new('X509Certificate', xml)
      #x509_certificate.content = certificado.certificate.to_s.gsub(/\-\-\-\-\-[A-Z]+ CERTIFICATE\-\-\-\-\-/, "").gsub(/\n/,"")

      #x509_data.add_child x509_certificate
      #key_info.add_child x509_data

      ## 5.2 Add KeyInfo
      #signature.add_child key_info

      ## 6 Add Signature
      #xml.root().add_child signature

      #end
      # Return XML
      xml.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
    end

    def assinatura_cancelamento_n_fe(data)
      part_1 = data[:inscricao_prestador].rjust(8,'0')
      part_2 = data[:numero_nfe].rjust(12,'0')
      value = part_1 + part_2
      assinatura_simples(value)
    end
    
    def assinatura_envio_rps(data)
      part_1 = data[:inscricao_prestador].rjust(8,'0')
      part_2 = data[:serie_rps].ljust(5)
      part_3 = data[:numero_rps].rjust(12,'0')
      part_4 = data[:data_emissao].delete('-')
      part_5 = data[:tributacao_rps]
      part_6 = data[:status_rps]
      part_7 = data[:iss_retido] ? 'S' : 'N'
      part_8 = data[:valor_servicos].delete(',').delete('.').rjust(15,'0')
      part_9 = data[:valor_deducoes].delete(',').delete('.').rjust(15,'0')
      part_10 = data[:codigo_servico].rjust(5,'0')
      part_11 = (data[:cpf_tomador].blank? ? (data[:cnpj_tomador].blank? ? '3' : '2') : '1')
      part_12 = (data[:cpf_tomador].blank? ? (data[:cnpj_tomador].blank? ? "".rjust(14,'0') : data[:cnpj_tomador].rjust(14,'0') ) : data[:cpf_tomador].rjust(14,'0'))
=begin
      part_13 = (data[:cpf_intermediario].blank? ? (data[:cnpj_intermediario].blank? ? '3' : '2') : '1')
      part_14 = (data[:cpf_intermediario].blank? ? (data[:cnpj_intermediario].blank? ? "".rjust(14,'0') : data[:cnpj_intermediario].rjust(14,'0') ) : data[:cpf_intermediario].rjust(14,'0'))
      part_15 = data[:iss_retido_intermediario] ? 'S' : 'N'
=end

      #value = part_1 + part_2 + part_3 + part_4 + part_5 + part_6 + part_7 + part_8 + part_9 + part_10 + part_11 + part_12 + part_13 + part_14 + part_15
      value = part_1 + part_2 + part_3 + part_4 + part_5 + part_6 + part_7 + part_8 + part_9 + part_10 + part_11 + part_12

      assinatura_simples(value)
    end

    def assinatura_simples(value)
      #sign_hash = certificado.key.sign( OpenSSL::Digest::SHA1.new, value )
      #Base64.encode64( sign_hash ).gsub("\n",'').gsub("\r",'').strip()
      value
    end

  end
end
