*Making use of SAP's run-time type services, we can pass almost anything we might want to log to an instance of ZIF_LOGGER, and it will do the heavy lifting.
*
*Log a string:
*
*log->s( 'Document 4800095710 created successfully' ).
*Log a bapi return message:
*
*DATA: rtn TYPE bapiret2.
*log->add( rtn ).
*Log a table of bapi return messages:
*
*DATA: msgs TYPE TABLE OF bapiret2.
*log->add( msgs ).
*Log an HR error message
*
*DATA: hr_msg TYPE HRPAD_MESSAGE .
*log->add( hr_msg ).
*Log an exception:
*
*TRY.
*    rubber_band_powered_spaceship=>fly_to( the_moon ).
*  CATCH zcx_not_enough_power INTO err.
*    log->e( err ).
*ENDTRY.
*Log the current system message:
*
*MESSAGE e001(oo) WITH foo bar baz INTO dummy.
*log->add( ). "you don't even need to pass anything in, bro.
*Log the return of a BDC call:
*
*CALL TRANSACTION 'CO07' USING bdc_tab MESSAGES INTO bdc_messages.
*log->add( bdc_messages ).
*And that's every scenario I've been able to think of, so far.
report z_test_app_log.
load-of-program.

top-of-page."在页首输出时触发。

initialization."在程序开始执行时初始化数据时触发。

at selection-screen output."在屏幕选择数据输出时触发。PBO
*在这个事件里声明的变量都是局部变量。

*数据选择和处理事件."
at selection-screen."在屏幕选择执行的时候,点击执行PAI

start-of-selection."点击执行后的主程序代码。

end-of-selection."选择数据结束时触发。

end-of-page."在页尾输出时触发。
