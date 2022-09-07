*&---------------------------------------------------------------------*
*& Report ZFI0048
*&---------------------------------------------------------------------*
*&
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

REPORT zfi0048.

INCLUDE zfi0048_top.
INCLUDE zfi0048_ssc.
INCLUDE zfi0048_f01.

START-OF-SELECTION.

  DATA(arquivo) = NEW lcl_monta_arquivo( ).

  CLEAR: gs_message,
         gv_execute.

  "Verifica se o programa roda em background
  arquivo->check_execucao( ).

  CHECK gs_message IS INITIAL.

  IF sy-batch EQ abap_true AND gv_execute EQ abap_false.
    EXIT.
  ENDIF.

  arquivo->buscar_dados( ).