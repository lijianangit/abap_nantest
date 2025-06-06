*******************************************************************
*   system-defined include-files.                                 *
*******************************************************************

 include lzfunctiongrouptop.                " global declarations
 include lzfunctiongroupuxx.                " function modules

 data d1 type ztestluw02.
 types t1 like d1.

 type-pools: znan."引入类型池，这里是全局使用的类型

*******************************************************************
*   user-defined include-files (if necessary).                    *
*******************************************************************
* include lzfunctiongroupf...                " subroutines
* include lzfunctiongroupo...                " pbo-modules
* include lzfunctiongroupi...                " pai-modules
* include lzfunctiongroupe...                " events
* include lzfunctiongroupp...                " local class implement.
* include lzfunctiongroupt99.                " abap unit tests
