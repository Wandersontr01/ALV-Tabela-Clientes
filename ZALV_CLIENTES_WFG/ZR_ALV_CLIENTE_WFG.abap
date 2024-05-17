*&---------------------------------------------------------------------*
*& Report ZR_ALV_CLIENTE_WFG
*&---------------------------------------------------------------------*
*& ALV Clientes WFG
*&
*& Wanderson Franca
*& https://www.linkedin.com/in/wandersonfg/
*& 
*& O programa Monta e exibe uma ALV da tabela interna 
*&
*&---------------------------------------------------------------------*
REPORT zr_alv_cliente_wfg NO STANDARD PAGE HEADING.

*--------------------------------------------------------------------*
* Declaraçoes
*--------------------------------------------------------------------*
DATA: gs_response TYPE zmft_cli_wfg,
      gt_response TYPE TABLE OF zmft_cli_wfg, "tabela interna
      lo_table    TYPE REF TO cl_salv_table,
      lt_fieldcat TYPE lvc_t_fcat,
      gt_fieldcat TYPE slis_t_fieldcat_alv.

*--------------------------------------------------------------------*
* Tela de seleção de Filtro
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_cpf  TYPE zmft_cli_wfg-cpf,
              p_nome TYPE zmft_cli_wfg-nome.
  "cpf e nome do tipo do campo da tabela
SELECTION-SCREEN END OF BLOCK b1.

*--------------------------------------------------------------------*
* Execução
*--------------------------------------------------------------------*
PERFORM f_extrair_dados.

*--------------------------------------------------------------------*
* FORM - Extrair dados filtrados
*--------------------------------------------------------------------*
FORM f_extrair_dados.
  IF p_nome EQ '' AND p_cpf EQ ''.
    SELECT *
      FROM zmft_cli_wfg
      INTO TABLE gt_response.
  ELSE.
    SELECT *
      FROM zmft_cli_wfg
      INTO TABLE gt_response
      WHERE nome = p_nome OR cpf = p_cpf.
  ENDIF.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE: 'Pesquisa não realizada' TYPE 'I' DISPLAY LIKE 'E'.
  ELSE.
    MESSAGE: 'Pesquisa realizada com sucesso' TYPE 'S'.
*    PERFORM f_alv.
    PERFORM f_imprime_log.
  ENDIF.
ENDFORM. "f_extrair_dados


*--------------------------------------------------------------------*
* FORM - Monta e exibe alv
*--------------------------------------------------------------------*
*FORM f_alv.
*  "monta o ALV com a lista dos programas
*  CALL METHOD cl_salv_table=>factory
*    IMPORTING
*      r_salv_table = lo_table
*    CHANGING
*      t_table      = gt_response.
*
*  "Mostra o ALV na tela
*  CALL METHOD lo_table->display.
*ENDFORM. "f_alv


FORM f_imprime_log.
  IF sy-subrc IS INITIAL.
    PERFORM f_create_fcatmanual.
  ELSE.
    MESSAGE: 'Não existem dados na tabela' TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM. "f_imprime_log


FORM f_create_fcatmanual.
  gt_fieldcat = VALUE slis_t_fieldcat_alv(
                                           (  fieldname = 'CPF'             outputlen = 14  reptext_ddic = 'CPF'               edit_mask = '___.___.___-__' )
                                           (  fieldname = 'IDCLIENTE'       outputlen = 10  reptext_ddic = 'ID Cliente'                                     )
                                           (  fieldname = 'NOME'            outputlen = 30  reptext_ddic = 'Nome Cliente'                                   )
                                           (  fieldname = 'DTNASCIMENTO'    outputlen = 14  reptext_ddic = 'Data Nascimento'   edit_mask = '__/__/____'     )
                                           (  fieldname = 'INATIVO'         outputlen = 7   reptext_ddic = 'Inativo'                                        )
                                           (  fieldname = 'USRCRIACAO'      outputlen = 12  reptext_ddic = 'Usuário Criação'                                )
                                           (  fieldname = 'DTCRIACAO'       outputlen = 14  reptext_ddic = 'Data de Criação'   edit_mask = '__/__/____'     )
                                           (  fieldname = 'HRCRIACAO'       outputlen = 15  reptext_ddic = 'Hora da Criação'                                )
                                           (  fieldname = 'USRALTERACAO'    outputlen = 12  reptext_ddic = 'Usuário Alteração'                              )
                                           (  fieldname = 'DTALTERACAO'     outputlen = 14  reptext_ddic = 'Data da Alteração' edit_mask = '__/__/____'     ) "O campo vazio com máscara é preenchido com ZEROS
                                           (  fieldname = 'HRALTERACAO'     outputlen = 15  reptext_ddic = 'Hora da Alteração'                              )
                                           ).

  PERFORM f_display_alv.

ENDFORM. "f_create_fcatmanual


FORM f_display_alv.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat        = gt_fieldcat
    TABLES
      t_outtab           = gt_response
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

ENDFORM. "f_display_alv