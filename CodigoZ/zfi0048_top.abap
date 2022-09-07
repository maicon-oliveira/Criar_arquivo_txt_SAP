*&---------------------------------------------------------------------*
*& Include          ZFI0048_TOP
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

TABLES: bseg,
        t003t.

DATA: gs_message TYPE char100,
      gv_execute TYPE c.

"estrutura que busca os valores de item e header"
TYPES: BEGIN OF ty_valores,
         bukrs   TYPE bseg-bukrs,
         kunnr   TYPE bseg-kunnr,
         vertn   TYPE bseg-vertn,
         zuonr   TYPE bseg-zuonr,
         belnr   TYPE bseg-belnr,
         disbn   TYPE bseg-disbn,
         h_blart TYPE bseg-h_blart,
         bzdat   TYPE bseg-bzdat,
         h_bldat TYPE bseg-h_bldat,
         dmbtr   TYPE bseg-dmbtr,
         pswsl   TYPE bseg-pswsl,
         h_budat TYPE bseg-h_budat,
         netdt   TYPE bseg-netdt,
         xref1   TYPE bseg-xref1,
         xref3   TYPE bseg-xref3,
         zlsch   TYPE bseg-zlsch,
         sgtxt   TYPE bseg-sgtxt,
         augbl   TYPE bseg-augbl,
         ltext   TYPE t003t-ltext,
       END OF ty_valores,
       
       "Estrutura do header
       BEGIN OF ty_header,
         campo1  TYPE char8,
         campo2  TYPE char11,
         campo3  TYPE char9,
         campo4  TYPE char15,
         campo5  TYPE char50,
         campo6  TYPE char5,
         campo7  TYPE char22,
         campo8  TYPE char11,
         campo9  TYPE char11,
         campo10 TYPE char13,
         campo11 TYPE char6,
         campo12 TYPE char50,
         campo13 TYPE char08,
         campo14 TYPE char10,
         campo15 TYPE char25,
         campo16 TYPE char15,
         campo17 TYPE char15,
       END OF ty_header,

       "estrutura do item
       BEGIN OF ty_item,
         campo1  TYPE char8,
         campo2  TYPE char11,
         campo3  TYPE char13,
         campo4  TYPE char19,
         campo5  TYPE char11,
         campo6  TYPE char11,
         campo7  TYPE char4,
         campo8  TYPE char11,
         campo9  TYPE char11,
         campo10 TYPE char13,
         campo11 TYPE char8,
         campo12 TYPE char11,
         campo13 TYPE char13,
         campo14 TYPE char11,
         campo15 TYPE char21,
         campo16 TYPE char3,
         campo17 TYPE char50,
         campo18 TYPE char11,
       END OF ty_item.

CLASS lcl_monta_arquivo DEFINITION.
  PUBLIC SECTION.
    METHODS:
      check_execucao,
      buscar_dados,
      gerar_arquivo,
      gerar_arquivo_item,
      range_select_options.


    DATA: it_valores   TYPE TABLE OF ty_valores,
          it_string    TYPE TABLE OF string,
          it_header    TYPE TABLE OF ty_header,
          it_item      TYPE TABLE OF ty_item,
          wa_header    TYPE ty_header,
          wa_item      TYPE ty_item,
          it_txt       TYPE truxs_t_text_data,
          wa_txt       LIKE LINE OF it_txt,
          lv_diretorio TYPE string.

ENDCLASS.