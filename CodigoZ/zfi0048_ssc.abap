*&---------------------------------------------------------------------*
*& Include          ZFI0048_SSC
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

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_bukrs FOR bseg-bukrs,
                s_kunnr FOR bseg-kunnr,
                s_budat FOR bseg-h_budat.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-002.
PARAMETERS: p_local RADIOBUTTON GROUP rad1,
            p_file1 TYPE rlgrap-filename,
            p_serv  RADIOBUTTON GROUP rad1 DEFAULT 'X',
            p_file2 TYPE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK b02.