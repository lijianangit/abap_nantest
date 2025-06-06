*&---------------------------------------------------------------------*
*& Report ZNANTEST2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT znantest2.


*初始化的一些工作
INITIALIZATION.
  WRITE / 'initialization'.
  TYPES: BEGIN OF type1,
           vbeln TYPE vbeln_va,
           posnr TYPE posnr_va,
           matnr TYPE Matnr,
         END OF type1.
  DATA tab1 TYPE TABLE OF type1.

  DATA str1 TYPE string.
  str1 = |Matnr = 'MZ-TG-Y120 '|.
*数据库查询
START-OF-SELECTION.
  SELECT  vbeln posnr Matnr FROM vbap INTO
  TABLE tab1 WHERE  (str1).

END-OF-SELECTION.
  DATA len TYPE i .
  WRITE / lines( tab1 ).




*IF lines( tab1 ) > 0.
* WRITE / 'xxxxx'.
* ELSE.
*   MESSAGE '未查询到数据' TYPE 'E'.
*  ENDIF.
