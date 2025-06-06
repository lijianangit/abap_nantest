*&---------------------------------------------------------------------*
*& Report Ztestcds
*&---------------------------------------------------------------------*
*& 测试CDS core  database Services

*&---------------------------------------------------------------------*
REPORT Ztestcds.



*类定义
CLASS Demo DEFINITION.
*  公共块
  PUBLIC SECTION.
*  类方法
    CLASS-METHODS:
*  构造方法的定义
      Class_constructor,
      Main.
*  私有块
  PRIVATE SECTION.
*  定理类型
    TYPES: Wa1 TYPE Demo_join1,
           Wa2 TYPE Demo_join2,
           Wa3 TYPE Demo_join3.
*  定义类型
    TYPES BEGIN OF Wa.
    INCLUDE TYPE Wa1 AS Wa1 RENAMING WITH SUFFIX _1.
    INCLUDE TYPE Wa2 AS Wa2 RENAMING WITH SUFFIX _2.
    INCLUDE TYPE Wa3 AS Wa3 RENAMING WITH SUFFIX _3.
    TYPES END OF Wa.
    CLASS-DATA Out TYPE REF TO If_demo_output.
ENDCLASS.
*具体实现
CLASS Demo IMPLEMENTATION.
  METHOD Main.
    DATA:
      Path_outer TYPE TABLE OF Demo_cds_assoc_join1_o WITH DEFAULT KEY,
      Path_inner TYPE TABLE OF Demo_cds_assoc_join1_i WITH DEFAULT KEY,
      Join_outer TYPE TABLE OF Wa WITH DEFAULT KEY,
      Join_inner TYPE TABLE OF Wa WITH DEFAULT KEY.
    Out->begin_section( 'Cds Views'
    )->Begin_section( 'Path With [Left Outer]' ).


*    查询数据 left
    SELECT *
    FROM Demo_cds_assoc_join1_o
    INTO TABLE @Path_outer.

*      排序
    SORT Path_outer.



*   查询数据 inner
    Out->write( Path_outer
    )->Next_section( 'Path With [Inner]' ).

    SELECT *
    FROM Demo_cds_assoc_join1_i
    INTO TABLE @Path_inner.

    SORT Path_inner.


    Out->write( Path_inner
    )->End_section( )->End_section(
    )->Begin_section( `Open Sql Joins`
    )->Begin_section(
    `Left Outer Joins` ).

    SELECT FROM
    Demo_cds_assoc_join1_o AS t1
    LEFT OUTER JOIN
    Demo_cds_assoc_join2 AS t2 ON t2~d = t1~d_1
    LEFT OUTER JOIN
    Demo_join3 AS t3 ON t3~l = t2~d

    FIELDS t1~a_1,
    t1~b_1,
    t1~c_1,
    t1~d_1,
    t2~d AS d_2,
    t2~e AS e_2,
    t2~f AS f_2,
    t2~g AS g_2,
    t2~h AS h_2,
    t3~i AS i_3,
    t3~j AS j_3,
    t3~k AS k_3,
    t3~l AS l_3
    INTO CORRESPONDING FIELDS OF TABLE @Join_outer.




    SORT Join_outer.


    Out->write( Join_outer
    )->Next_section( `Inner Joins` ).

    SELECT FROM
    Demo_cds_assoc_join1_i AS t1
    INNER JOIN
    Demo_cds_assoc_join2 AS t2 ON t2~d = t1~d_1
    INNER JOIN
    Demo_join3 AS t3 ON t3~l = t2~d
    FIELDS t1~a_1,
    t1~b_1,
    t1~c_1,
    t1~d_1,
    t2~d AS d_2,
    t2~e AS e_2,
    t2~f AS f_2,
    t2~g AS g_2,
    t2~h AS h_2,
    t3~i AS i_3,
    t3~j AS j_3,
    t3~k AS k_3,
    t3~l AS l_3
    INTO CORRESPONDING FIELDS OF TABLE @Join_inner.


    SORT Join_inner.

    Out->write( Join_inner )->Display( ).

    ASSERT Path_inner = Join_inner.
    ASSERT Path_outer = Join_outer.
  ENDMETHOD.




  METHOD Class_constructor.
    Out = Cl_demo_output=>new( )->Begin_section( `Database Tables` ).
    DELETE FROM Demo_join1.
    INSERT Demo_join1 FROM TABLE @( VALUE #(
    ( a = 'A1' b = 'B1' c = 'C1' d = 'Uu' )
    ( a = 'A2' b = 'B2' c = 'C2' d = 'Uu' )
    ( a = 'A3' b = 'B3' c = 'C3' d = 'Vv' )
    ( a = 'A4' b = 'B4' c = 'C4' d = 'Ww' ) ) ).
    SELECT * FROM Demo_join1 INTO TABLE @DATA(itab1).
    DELETE FROM Demo_join2.
    INSERT Demo_join2 FROM TABLE @( VALUE #(
    ( d = 'Uu' e = 'E1' f = 'F1' g = 'G1'  h = 'H1' )
    ( d = 'Ww' e = 'E2' f = 'F2' g = 'G2'  h = 'H2' )
    ( d = 'Xx' e = 'E3' f = 'F3' g = 'G3'  h = 'H3' ) ) ).
    SELECT * FROM Demo_join2 INTO TABLE @DATA(itab2).
    DELETE FROM Demo_join3.
    INSERT Demo_join3 FROM TABLE @( VALUE #(
    ( i = 'I1' j = 'J1' k = 'K1' l = 'Vv' )
    ( i = 'I2' j = 'J2' k = 'K2' l = 'Vv' )
    ( i = 'I3' j = 'J3' k = 'K3' l = 'Ww' ) ) ).
    SELECT * FROM Demo_join3 INTO TABLE @DATA(itab3).
    Out->begin_section( `Demo_join1`
    )->Write( Itab1
    )->Next_section( `Demo_join2`
    )->Write( Itab2
    )->Next_section( `Demo_join3`
    )->Write( Itab3
    )->End_section(
    )->End_section( ).
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  Demo=>main( ).
