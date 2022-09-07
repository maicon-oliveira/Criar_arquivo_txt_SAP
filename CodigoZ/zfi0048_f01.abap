*&---------------------------------------------------------------------*
*& Include          ZFI0048_F01
*&---------------------------------------------------------------------*
************************************************************************
* Programa     : ZFI0048                                               *
* Description  : Gerar Arquivo .txt para Integração Portal Cliente     *
* Module       : FI & SD                                               *
* Author       : Maicon Oliveira  - Fusion                             *
* Date         : 20/05/2022                                            *
*&---------------------------------------------------------------------*
* Histórico das Alterações                                             *
*&---------------------------------------------------------------------*
* Usuário |  Data      | Request    | Descrição                        *
* FUSIONF | 20/05/2020 | S4DK910910 | Codificação inicial              *
*&---------------------------------------------------------------------*

CLASS lcl_monta_arquivo IMPLEMENTATION.

    METHOD check_execucao.
  
      IF s_bukrs IS INITIAL.
        gs_message = TEXT-010.
  
        MESSAGE s019(zfi) WITH gs_message.
      ENDIF.
      IF s_budat IS INITIAL.
        IF sy-batch IS INITIAL.
          gs_message = TEXT-011.
          MESSAGE s019(zfi) WITH gs_message.
        ELSE.
          me->range_select_options( ).
          IF sy-uzeit BETWEEN '115900' AND '120500' OR
            sy-uzeit BETWEEN  '175900' AND '180500'.
            gv_execute = abap_true.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDMETHOD.
  
    METHOD buscar_dados.
  
      DATA: lv_qtd TYPE i.
  
      SELECT  a~bukrs
              a~kunnr
              a~vertn
              a~zuonr
              a~belnr
              a~disbn
              a~h_blart
              a~bzdat
              a~h_bldat
              a~dmbtr
              a~pswsl
              a~h_budat
              a~netdt
              a~xref1
              a~xref3
              a~zlsch
              a~sgtxt
              a~augbl
              b~ltext
      FROM bseg AS a
      INNER JOIN t003t AS b
      ON b~blart = a~h_blart
      INTO CORRESPONDING FIELDS OF TABLE it_valores
      WHERE a~bukrs   IN s_bukrs
      AND   a~kunnr   IN s_kunnr
      AND   a~h_budat IN s_budat
      AND   b~spras = 'PT'
      AND   ( a~h_blart = 'Z0' OR a~h_blart = 'Z9' ).
  
  
      IF sy-subrc = 0.
  
        "Passa os items para o header do arquivo
        APPEND VALUE #( campo1  = 'Empresa|'
                        campo2  = 'Parc.lçto.|'
                        campo3  = 'Contrato|'
                        campo4  = 'Contrato.ant  |'
                        campo5  = 'Den.set.ind.                                     |'
                        campo6  = 'TpCd|'
                        campo7  = 'Tipo de Condição     |'
                        campo8  = 'Início    |'
                        campo9  = 'Fim absol.|'
                        campo10 = 'Condição    |'
                        campo11 = 'Moeda|'
                        campo12 = 'Denominação                                      |'
                        campo13 = 'CoES   |'
                        campo14 = 'Executivo|'
                        campo15 = 'Nome Executivo de Contas|'
                        campo16 = 'Reajuste      |'
                        campo17 = '1° Reajuste   |' ) TO it_header.
  
        LOOP AT it_valores REFERENCE INTO DATA(lsr_dados).
          wa_header-campo1  = lsr_dados->bukrs.
          wa_header-campo2  = lsr_dados->kunnr.
          wa_header-campo3  = lsr_dados->vertn.
          wa_header-campo4  = lsr_dados->bukrs && lsr_dados->vertn.
  
          IF lsr_dados->sgtxt IS NOT INITIAL.
            lv_qtd = strlen( lsr_dados->sgtxt ).
            IF lv_qtd > 1.
              lv_qtd = lv_qtd - 1.
            ENDIF.
            wa_header-campo5  = lsr_dados->sgtxt+0(lv_qtd).
          ENDIF.
          wa_header-campo6  = lsr_dados->h_blart.
          wa_header-campo7  = lsr_dados->ltext.
          wa_header-campo8  = '01.01.2019'.
          wa_header-campo9  = '31.12.9999'.
          wa_header-campo10 = lsr_dados->dmbtr.
          wa_header-campo11 = lsr_dados->pswsl.
          wa_header-campo12 = lsr_dados->sgtxt+0(lv_qtd).
          wa_header-campo13 = ''. "em branco
          wa_header-campo14 = 'JFRIOLIM'.
          wa_header-campo15 = 'Janice Friolim Nogueira'.
          wa_header-campo16 = ''. "em branco
          wa_header-campo17 = ''. "em branco.
  
          MOVE '|' TO wa_header+7(1).
          MOVE '|' TO wa_header+18(1).
          MOVE '|' TO wa_header+27(1).
          MOVE '|' TO wa_header+42(1).
          MOVE '|' TO wa_header+92(1).
          MOVE '|' TO wa_header+97(1).
          MOVE '|' TO wa_header+119(1).
          MOVE '|' TO wa_header+130(1).
          MOVE '|' TO wa_header+141(1).
          MOVE '|' TO wa_header+154(1).
          MOVE '|' TO wa_header+160(1).
          MOVE '|' TO wa_header+210(1).
          MOVE '|' TO wa_header+218(1).
          MOVE '|' TO wa_header+228(1).
          MOVE '|' TO wa_header+253(1).
          MOVE '|' TO wa_header+268(1).
          MOVE '|' TO wa_header+283(1).
  
          APPEND wa_header TO it_header.
  
        ENDLOOP.
  
*      CALL FUNCTION 'SAP_CONVERT_TO_TEX_FORMAT'
*        EXPORTING
*          i_field_seperator    = '|'
*          i_line_header        = 'X'
*        TABLES
*          i_tab_sap_data       = it_header
*        CHANGING
*          i_tab_converted_data = it_txt
*        EXCEPTIONS
*          conversion_failed    = 1
*          OTHERS               = 2.
*      IF sy-subrc <> 0.
** Implement suitable error handling here
*      ENDIF.
        me->gerar_arquivo( ).
        me->gerar_arquivo_item( ).
        MESSAGE 'Arquivos Carregados com Sucesso' TYPE 'S'.
      ELSE.
        MESSAGE 'Não há dados para serem processados' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    ENDMETHOD.
  
    METHOD gerar_arquivo.
      "Gerar arquivo no servidor
      IF p_serv IS NOT INITIAL.
  
        IF p_file2 IS INITIAL.
  
          IF s_bukrs-low = 'FOR'.
            "Seleciona o doretório empresa FOR
            SELECT SINGLE low
              FROM tvarvc
              INTO lv_diretorio
              WHERE name = 'Z_PORTALCLIENTE_TPDOC_FOR_H'.
  
          ELSEIF s_bukrs-low = 'POA'.
            "Seleciona o diretório empresa POA
            SELECT SINGLE low
             FROM tvarvc
             INTO lv_diretorio
             WHERE name = 'Z_PORTALCLIENTE_TPDOC_POA_H'.
  
          ENDIF.
  
        ELSE.
          "Diretório servidor manual
          lv_diretorio = p_file2.
  
        ENDIF.
  
        "gera o arquivo no servidor
        OPEN DATASET lv_diretorio FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSE.
  
          LOOP AT it_header INTO wa_header.
            TRANSFER wa_header TO lv_diretorio.
          ENDLOOP.
        ENDIF.
        CLOSE DATASET lv_diretorio.
  
      ELSE.
  
        "gera arquivo local
        CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
          CHANGING
            file_name     = p_file1
          EXCEPTIONS
            mask_too_long = 1
            OTHERS        = 2.
        IF sy-subrc <> 0.
  * Implement suitable error handling here
        ENDIF.
  
        DATA(filename) = CONV string( p_file1 ).
  
        CALL FUNCTION 'GUI_DOWNLOAD'
          EXPORTING
            filename                = filename
            filetype                = 'ASC'
          TABLES
            data_tab                = it_header
          EXCEPTIONS
            file_write_error        = 1
            no_batch                = 2
            gui_refuse_filetransfer = 3
            invalid_type            = 4
            no_authority            = 5
            unknown_error           = 6
            header_not_allowed      = 7
            separator_not_allowed   = 8
            filesize_not_allowed    = 9
            header_too_long         = 10
            dp_error_create         = 11
            dp_error_send           = 12
            dp_error_write          = 13
            unknown_dp_error        = 14
            access_denied           = 15
            dp_out_of_memory        = 16
            disk_full               = 17
            dp_timeout              = 18
            file_not_found          = 19
            dataprovider_exception  = 20
            control_flush_error     = 21
            OTHERS                  = 22.
        IF sy-subrc <> 0.
  * Implement suitable error handling here
        ENDIF.
  
      ENDIF.
    ENDMETHOD.
  
    METHOD gerar_arquivo_item.
  
      DATA: lv_qtd_i      TYPE i.
  
      CLEAR: it_txt.
  
      "monta cabeçalho do arquivo de item
      APPEND VALUE #( campo1  = 'Empresa|'
                      campo2  = 'Conta     |'
                      campo3  = 'N° Contrato |'
                      campo4  = 'Atribuição        |'
                      campo5  = 'N° Doc    |'
                      campo6  = 'Solic. L/C|'
                      campo7  = 'Tip|'
                      campo8  = 'Data refer|'
                      campo9  = 'Data doc. |'
                      campo10 = 'Mont. em MI |'
                      campo11 = 'Moeda I|'
                      campo12 = 'Data lçto |'
                      campo13 = 'Venc Líquido|'
                      campo14 = 'Chv.ref.1 |'
                      campo15 = 'Chave Referência 3  |'
                      campo16 = 'MP|'
                      campo17 = 'Texto                                            |'
                      campo18 = 'DocCompens|' ) TO it_item.
  
      LOOP AT me->it_valores REFERENCE INTO DATA(lsr_valores).
  
        wa_item-campo1 = lsr_valores->bukrs.
        wa_item-campo2  = lsr_valores->kunnr.
        wa_item-campo3  = lsr_valores->vertn.
        wa_item-campo4  = lsr_valores->zuonr.
        wa_item-campo5  = lsr_valores->belnr.
        wa_item-campo6  = lsr_valores->disbn.
        wa_item-campo7  = lsr_valores->h_blart.
        wa_item-campo8  = lsr_valores->bzdat.
        CONCATENATE wa_item-campo8+6(2)'.'
                    wa_item-campo8+4(2)'.'
                    wa_item-campo8(4)
                    INTO wa_item-campo8.
  
        wa_item-campo9  = lsr_valores->h_bldat.
        CONCATENATE wa_item-campo9+6(2)'.'
                    wa_item-campo9+4(2)'.'
                    wa_item-campo9(4)
                    INTO wa_item-campo9.
  
        wa_item-campo10 = lsr_valores->dmbtr.
        wa_item-campo11 = lsr_valores->pswsl.
        wa_item-campo12 = lsr_valores->h_budat.
        CONCATENATE wa_item-campo12+6(2)'.'
                    wa_item-campo12+4(2)'.'
                    wa_item-campo12(4)
                    INTO wa_item-campo12.
  
        wa_item-campo13 = lsr_valores->netdt.
        CONCATENATE wa_item-campo13+6(2)'.'
                    wa_item-campo13+4(2)'.'
                    wa_item-campo13(4)
                    INTO wa_item-campo13.
  
        wa_item-campo14 = lsr_valores->xref1.
        wa_item-campo15 = lsr_valores->xref3.
        wa_item-campo16 = lsr_valores->zlsch.
  
        IF lsr_valores->sgtxt IS NOT INITIAL.
          lv_qtd_i = strlen( lsr_valores->sgtxt ).
          IF lv_qtd_i > 1.
            lv_qtd_i = lv_qtd_i - 1.
          ENDIF.
          wa_item-campo17 = lsr_valores->sgtxt+0(lv_qtd_i).
        ENDIF.
        wa_item-campo18 = lsr_valores->augbl.
  
        MOVE '|' TO wa_item+7(1).
        MOVE '|' TO wa_item+18(1).
        MOVE '|' TO wa_item+31(1).
        MOVE '|' TO wa_item+50(1).
        MOVE '|' TO wa_item+61(1).
        MOVE '|' TO wa_item+72(1).
        MOVE '|' TO wa_item+76(1).
        MOVE '|' TO wa_item+87(1).
        MOVE '|' TO wa_item+98(1).
        MOVE '|' TO wa_item+111(1).
        MOVE '|' TO wa_item+119(1).
        MOVE '|' TO wa_item+130(1).
        MOVE '|' TO wa_item+143(1).
        MOVE '|' TO wa_item+154(1).
        MOVE '|' TO wa_item+175(1).
        MOVE '|' TO wa_item+178(1).
        MOVE '|' TO wa_item+228(1).
        MOVE '|' TO wa_item+239(1).
  
        APPEND wa_item TO it_item.
  
      ENDLOOP.
  
*    CALL FUNCTION 'SAP_CONVERT_TO_TEX_FORMAT'
*      EXPORTING
*        i_field_seperator    = '|'
*        i_line_header        = 'X'
*      TABLES
*        i_tab_sap_data       = it_item
*      CHANGING
*        i_tab_converted_data = it_txt
*      EXCEPTIONS
*        conversion_failed    = 1
*        OTHERS               = 2.
*    IF sy-subrc <> 0.
** Implement suitable error handling here
*    ENDIF.
  
      "Gerar arquivo no servidor
      IF p_serv IS NOT INITIAL.
  
        IF p_file2 IS INITIAL.
  
          IF s_bukrs-low = 'FOR'.
            "Seleciona o doretório empresa FOR
            SELECT SINGLE low
              FROM tvarvc
              INTO lv_diretorio
              WHERE name = 'Z_PORTALCLIENTE_TPDOC_FOR_I'.
  
          ELSEIF s_bukrs-low = 'POA'.
            "Seleciona o diretório empresa POA
            SELECT SINGLE low
             FROM tvarvc
             INTO lv_diretorio
             WHERE name = 'Z_PORTALCLIENTE_TPDOC_POA_I'.
  
          ENDIF.
  
        ELSE.
  
          "retira os 4 ultimos caracteres da variável
          lv_diretorio = substring( val = lv_diretorio off = 0 len = strlen( lv_diretorio ) - 4 ).
          lv_diretorio = lv_diretorio && '_item.txt'.
  
        ENDIF.
  
  
        OPEN DATASET lv_diretorio FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSE.
  
          LOOP AT it_item INTO wa_item.
            TRANSFER wa_item TO lv_diretorio.
          ENDLOOP.
        ENDIF.
        CLOSE DATASET lv_diretorio.
  
      ELSE.
  
        "gera arquivo local
        CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
          CHANGING
            file_name     = p_file1
          EXCEPTIONS
            mask_too_long = 1
            OTHERS        = 2.
        IF sy-subrc <> 0.
  * Implement suitable error handling here
        ENDIF.
  
        DATA(filename) = CONV string( p_file1 ).
  
        CALL FUNCTION 'GUI_DOWNLOAD'
          EXPORTING
            filename                = filename
            filetype                = 'ASC'
          TABLES
            data_tab                = it_item
          EXCEPTIONS
            file_write_error        = 1
            no_batch                = 2
            gui_refuse_filetransfer = 3
            invalid_type            = 4
            no_authority            = 5
            unknown_error           = 6
            header_not_allowed      = 7
            separator_not_allowed   = 8
            filesize_not_allowed    = 9
            header_too_long         = 10
            dp_error_create         = 11
            dp_error_send           = 12
            dp_error_write          = 13
            unknown_dp_error        = 14
            access_denied           = 15
            dp_out_of_memory        = 16
            disk_full               = 17
            dp_timeout              = 18
            file_not_found          = 19
            dataprovider_exception  = 20
            control_flush_error     = 21
            OTHERS                  = 22.
        IF sy-subrc <> 0.
  * Implement suitable error handling here
        ENDIF.
      ENDIF.
  
    ENDMETHOD.
  
    METHOD range_select_options.
      DATA: date    TYPE RANGE OF bseg-h_budat,
            lv_date LIKE LINE OF date.
  
      lv_date-sign = 'I'.
      lv_date-option = 'EQ'.
      lv_date-low = sy-datum.
  
      APPEND lv_date TO s_budat.
    ENDMETHOD.
  
  
  ENDCLASS.