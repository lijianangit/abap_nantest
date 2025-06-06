*&---------------------------------------------------------------------*
*& 包含               ZMMR084_SCR
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk_01 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:so_ebeln FOR eban-ebeln MEMORY ID bes.
  SELECT-OPTIONS:so_bsmng FOR eban-bsmng.

  SELECT-OPTIONS:so_vbeln FOR ebkn-vbeln MEMORY ID aun.
  SELECT-OPTIONS:so_kostl FOR ebkn-kostl MEMORY ID kos.
  SELECT-OPTIONS:so_flief FOR eban-flief.
  SELECT-OPTIONS:so_ekorg FOR eban-ekorg MEMORY ID eko.
  SELECT-OPTIONS:so_lgort FOR eban-lgort MEMORY ID lag.
  SELECT-OPTIONS:so_matnr FOR eban-matnr MEMORY ID mat.
  SELECT-OPTIONS:so_werks FOR eban-werks MEMORY ID wrk.
  SELECT-OPTIONS:so_badat FOR eban-badat.
  SELECT-OPTIONS:so_ekgrp FOR eban-ekgrp MEMORY ID ekg.
  SELECT-OPTIONS:so_frgkz FOR eban-frgkz.
  SELECT-OPTIONS:so_frgst FOR eban-frgst.
  SELECT-OPTIONS:so_statu FOR eban-statu.
  SELECT-OPTIONS:so_loekz FOR eban-loekz.
  SELECT-OPTIONS:so_knttp FOR eban-knttp MEMORY ID knt.
  SELECT-OPTIONS:so_pstyp FOR eban-pstyp.
  SELECT-OPTIONS:so_bnfpo FOR eban-bnfpo MEMORY ID bap.
  SELECT-OPTIONS:so_banfn FOR eban-banfn MEMORY ID ban.
  SELECT-OPTIONS:so_bsart FOR eban-bsart MEMORY ID bba.
  SELECT-OPTIONS:so_dispo FOR eban-dispo MEMORY ID dis.
SELECTION-SCREEN END OF BLOCK blk_01.
