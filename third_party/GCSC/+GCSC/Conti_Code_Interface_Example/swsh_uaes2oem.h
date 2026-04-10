 /*<uaesHead>
 *************************************************************************
 *                                                                       *
 *                      ROBERT BOSCH GMBH                                *
 *                          STUTTGART                                    *
 *                                                                       *
 *          Alle Rechte vouaesehalten - All rights reserved                *
 *                                                                       *
 *************************************************************************

 *************************************************************************
 * Administrative Information (automatically filled in by [N]estor)  *
 *************************************************************************
 *
 * $Filename__:swsh_uaes2oem.h$
 *
 * $Author____:Zhang Jian$
 *
 * $Function__:Model 2 SWSH test version$
 *
 *************************************************************************
 * $Repository:SDOM$
 * $User______:jian.zhang3$
 * $Date______:05.01.2016$
 * $Class_____:SWHDR$
 * $Name______:swsh_uaes2oem$
 * $Variant___:U1.0.0$
 * $Revision__:0$
 * $Type______:H$
 * $State_____:Released$
 *************************************************************************
 * Points to be taken into consideration when/
 if the module is modified:
 *
 * $LinkTo____:$
 *
 *************************************************************************
 * List Of Changes
 *
 * $History
 * 
 *
 *************************************************************************
</uaesHead>*/

/* do not use protect multiple includes - this is not working with used pragma concept   */

/*****************************************************************************************/
/*                                                                                       */
/* The PRAGMA_UNUSED macro is used to know if the required pragma has been found or not  */
/* If it hasn't been found, the compilation failed with the following message:           */
/* "Error: The file swsh_uaes2oem.h has been included, but no pragma was found"           */
/*                                                                                       */
/*****************************************************************************************/

#define PRAGMA_UNUSED


/*************************************************************************************/
/*                             Pragmas for processes                                 */
/*************************************************************************************/
/*                                                                                   */
/*  OS_Ini_Task                         Task_OEM_rini                               */
/*  OS_10msSwoff_Task                     Task_OEM_r10msSwoff                                 */
/*  OS_1000msSwoff_Task                     Task_OEM_r1000msSwoff                             */
/*                                                                                   */
/*************************************************************************************/

/*************************************************************************************/
/*   Raster:  OS_Ini_Task                                                            */
/*   Pragma: Task_OEM_rini                                                          */
/*************************************************************************************/


#ifdef START_SECTION_Task_OEM_rini
    #pragma section .text.OEM_code_Task_ini ax
    #undef START_SECTION_Task_OEM_rini
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_Task_OEM_rini
    #pragma section
    #undef STOP_SECTION_Task_OEM_rini
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Raster:   OS_sync_Task                                                          */
/*   Pragma:  Task_OEM_rsync                                                        */
/*************************************************************************************/

#ifdef START_SECTION_Task_OEM_rsync
    #pragma section .text.OEM_code_Task_rsync ax
    #undef START_SECTION_Task_OEM_rsync
    #undef PRAGMA_UNUSED
#endif



#ifdef STOP_SECTION_Task_OEM_rsync
    #pragma section
    #undef STOP_SECTION_Task_OEM_rsync
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Raster:   OS_1ms_Task                                                          */
/*   Pragma:  Task_OEM_r1ms                                                        */
/*************************************************************************************/

#ifdef START_SECTION_Task_OEM_r1ms
    #pragma section .text.OEM_code_Task_r1ms ax
    #undef START_SECTION_Task_OEM_r1ms
    #undef PRAGMA_UNUSED
#endif



#ifdef STOP_SECTION_Task_OEM_r1ms
    #pragma section
    #undef STOP_SECTION_Task_OEM_r1ms
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Raster:   OS_5ms_Task                                                          */
/*   Pragma:  Task_OEM_r5ms                                                        */
/*************************************************************************************/

#ifdef START_SECTION_Task_OEM_r5ms
    #pragma section .text.OEM_code_Task_r5ms ax
    #undef START_SECTION_Task_OEM_r5ms
    #undef PRAGMA_UNUSED
#endif



#ifdef STOP_SECTION_Task_OEM_r5ms
    #pragma section
    #undef STOP_SECTION_Task_OEM_r5ms
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Raster:   OS_10ms_Task                                                          */
/*   Pragma:  Task_OEM_r10ms                                                        */
/*************************************************************************************/

#ifdef START_SECTION_Task_OEM_r10ms
    #pragma section .text.OEM_code_Task_r10ms ax
    #undef START_SECTION_Task_OEM_r10ms
    #undef PRAGMA_UNUSED
#endif



#ifdef STOP_SECTION_Task_OEM_r10ms
    #pragma section
    #undef STOP_SECTION_Task_OEM_r10ms
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Raster:   OS_10ms_Task                                                          */
/*   Pragma:  Task_OEM_r10ms                                                        */
/*************************************************************************************/

#ifdef START_SECTION_Task_OEM_r50ms
    #pragma section .text.OEM_code_Task_r50ms ax
    #undef START_SECTION_Task_OEM_r50ms
    #undef PRAGMA_UNUSED
#endif



#ifdef STOP_SECTION_Task_OEM_r50ms
    #pragma section
    #undef STOP_SECTION_Task_OEM_r50ms
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Raster:   OS_100ms_Task                                                        */
/*   Pragma:  Task_OEM_r100ms                                                      */
/*************************************************************************************/



#ifdef START_SECTION_Task_OEM_r100ms
    #pragma section .text.OEM_code_Task_r100ms ax
    #undef START_SECTION_Task_OEM_r100ms
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_Task_OEM_r100ms
    #pragma section
    #undef STOP_SECTION_Task_OEM_r100ms
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Raster:   OS_1000ms_Task                                                        */
/*   Pragma:  Task_OEM_r1000ms                                                      */
/*************************************************************************************/



#ifdef START_SECTION_Task_OEM_r1000ms
    #pragma section .text.OEM_code_Task_r1000ms ax
    #undef START_SECTION_Task_OEM_r1000ms
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_Task_OEM_r1000ms
    #pragma section
    #undef STOP_SECTION_Task_OEM_r1000ms
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Raster:   OS_1msSwoff_Task                                                          */
/*   Pragma:  Task_OEM_r1msSwoff                                                        */
/*************************************************************************************/

#ifdef START_SECTION_Task_OEM_r1msSwoff
    #pragma section .text.OEM_code_Task_r1msSwoff ax
    #undef START_SECTION_Task_OEM_r1msSwoff
    #undef PRAGMA_UNUSED
#endif



#ifdef STOP_SECTION_Task_OEM_r1msSwoff
    #pragma section
    #undef STOP_SECTION_Task_OEM_r1msSwoff
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Raster:   OS_5msSwoff_Task                                                          */
/*   Pragma:  Task_OEM_r5msSwoff                                                        */
/*************************************************************************************/

#ifdef START_SECTION_Task_OEM_r5msSwoff
    #pragma section .text.OEM_code_Task_r5msSwoff ax
    #undef START_SECTION_Task_OEM_r5msSwoff
    #undef PRAGMA_UNUSED
#endif



#ifdef STOP_SECTION_Task_OEM_r5msSwoff
    #pragma section
    #undef STOP_SECTION_Task_OEM_r5msSwoff
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Raster:   OS_10msSwoff_Task                                                          */
/*   Pragma:  Task_OEM_r10msSwoff                                                        */
/*************************************************************************************/

#ifdef START_SECTION_Task_OEM_r10msSwoff
    #pragma section .text.OEM_code_Task_r10msSwoff ax
    #undef START_SECTION_Task_OEM_r10msSwoff
    #undef PRAGMA_UNUSED
#endif



#ifdef STOP_SECTION_Task_OEM_r10msSwoff
    #pragma section
    #undef STOP_SECTION_Task_OEM_r10msSwoff
    #undef PRAGMA_UNUSED
#endif


/*************************************************************************************/
/*   Raster:   OS_50msSwoff_Task                                                          */
/*   Pragma:  Task_OEM_r50msSwoff                                                        */
/*************************************************************************************/

#ifdef START_SECTION_Task_OEM_r50msSwoff
    #pragma section .text.OEM_code_Task_r50msSwoff ax
    #undef START_SECTION_Task_OEM_r50msSwoff
    #undef PRAGMA_UNUSED
#endif



#ifdef STOP_SECTION_Task_OEM_r50msSwoff
    #pragma section
    #undef STOP_SECTION_Task_OEM_r50msSwoff
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Raster:   OS_100msSwoff_Task                                                        */
/*   Pragma:  Task_OEM_r100msSwoff                                                      */
/*************************************************************************************/



#ifdef START_SECTION_Task_OEM_r100msSwoff
    #pragma section .text.OEM_code_Task_r100msSwoff ax
    #undef START_SECTION_Task_OEM_r100msSwoff
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_Task_OEM_r100msSwoff
    #pragma section
    #undef STOP_SECTION_Task_OEM_r100msSwoff
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Raster:   OS_1000msSwoff_Task                                                        */
/*   Pragma:  Task_OEM_r1000msSwoff                                                      */
/*************************************************************************************/



#ifdef START_SECTION_Task_OEM_r1000msSwoff
    #pragma section .text.OEM_code_Task_r1000msSwoff ax
    #undef START_SECTION_Task_OEM_r1000msSwoff
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_Task_OEM_r1000msSwoff
    #pragma section
    #undef STOP_SECTION_Task_OEM_r1000msSwoff
    #undef PRAGMA_UNUSED
#endif


/*************************************************************************************/
/*                Pragmas for variables and structures                               */
/*************************************************************************************/

/*************************************************************************************/
/*                Pragmas for static variables and structures                        */
/*        ====================================================================       */
/*                                                                                   */
/*  								Memory location     							 */
/*                                                                                   */
/*					Official pragma supported by the Plattform						 */
/*                                                                                   */
/*	Section's name								Volatile	Speed	Protected	Size */
/*                                                                                   */
/*  OEM_volatile_FastRam_8bit				Yes			Fast	No			8	 */
/*  OEM_volatile_SlowRam_8bit				Yes			Slow	No			8	 */
/*                                                                                   */
/*  OEM_volatile_FastRam_16bit				Yes			Fast	No			16 	 */
/*  OEM_volatile_SlowRam_16bit				Yes			Slow	No			16 	 */
/*                                                                                   */
/*  OEM_volatile_FastRam_32bit				Yes			Fast	No			32 	 */
/*  OEM_volatile_SlowRam_32bit				Yes			Slow	No			32 	 */
/*                                                                                   */
/*  OEM_volatile_bit_fast			        Yes			Fast	No			1 	 */
/*  OEM_volatile_bit_slow			        Yes			Slow	No			8 	 */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/

/*************************************************************************************/
/*   Memory: Volatile, Fast, 8bits                                                   */
/*   Pragma: OEM_volatile_FastRam_8bit                                            */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_FastRam_8bit
    #pragma section .zbss.OEM.a1 awz
    #undef START_SECTION_OEM_volatile_FastRam_8bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_FastRam_8bit
    #pragma section
    #undef STOP_SECTION_OEM_volatile_FastRam_8bit
    #undef PRAGMA_UNUSED
#endif


/*************************************************************************************/
/*   Memory: Volatile, Slow, 8bits                                                   */
/*   Pragma: OEM_volatile_SlowRam_8bit                                            */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_SlowRam_8bit
    #pragma section .bss.OEM.a1 aw
    #undef START_SECTION_OEM_volatile_SlowRam_8bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_SlowRam_8bit
    #pragma section
    #undef STOP_SECTION_OEM_volatile_SlowRam_8bit
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Memory: Volatile, Fast, 16bits                                                  */
/*   Pragma: OEM_volatile_FastRam_16bit                                           */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_FastRam_16bit
    #pragma section .zbss.OEM.a2 awz
    #undef START_SECTION_OEM_volatile_FastRam_16bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_FastRam_16bit
    #pragma section
    #undef STOP_SECTION_OEM_volatile_FastRam_16bit
    #undef PRAGMA_UNUSED
#endif


/*************************************************************************************/
/*   Memory: Volatile, Slow, 16bits                                                  */
/*   Pragma: OEM_volatile_SlowRam_16bit                                           */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_SlowRam_16bit
    #pragma section .bss.OEM.a2 aw
    #undef START_SECTION_OEM_volatile_SlowRam_16bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_SlowRam_16bit
    #pragma section
    #undef STOP_SECTION_OEM_volatile_SlowRam_16bit
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Memory: Volatile, Fast, 32bits                                                  */
/*   Pragma: OEM_volatile_FastRam_32bit                                           */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_FastRam_32bit
    #pragma section .sbss.OEM.a4 aws
    #undef START_SECTION_OEM_volatile_FastRam_32bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_FastRam_32bit
    #pragma section
    #undef STOP_SECTION_OEM_volatile_FastRam_32bit
    #undef PRAGMA_UNUSED
#endif


/*************************************************************************************/
/*   Memory: Volatile, Slow, 32bits                                                  */
/*   Pragma: OEM_volatile_SlowRam_32bit                                           */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_SlowRam_32bit
    #pragma section .bss.OEM.a4 aw
    #undef START_SECTION_OEM_volatile_SlowRam_32bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_SlowRam_32bit
    #pragma section
    #undef STOP_SECTION_OEM_volatile_SlowRam_32bit
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Memory: volatile_bit, Fast, 1bit                                           */
/*   Pragma: OEM_volatile_bit_fast                                       */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_bit_fast
    #pragma section .bbss.OEM awbz
    #undef START_SECTION_OEM_volatile_bit_fast
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_bit_fast
    #pragma section
    #undef STOP_SECTION_OEM_volatile_bit_fast
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Memory: volatile_bit, Slow, 8bits                                          */
/*   Pragma: OEM_volatile_bit_slow                                       */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_bit_slow
    #pragma section .bss.OEM.a1 aw
    #undef START_SECTION_OEM_volatile_bit_slow
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_bit_slow
    #pragma section
    #undef STOP_SECTION_OEM_volatile_bit_slow
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*                Pragmas for static variables and structures                        */
/*        ====================================================================       */
/*                                                                                   */
/*  								Memory location     							 */
/*                                                                                   */
/*					Official pragma supported by the Plattform						 */
/*                                                                                   */
/*	Section's name								Volatile	Speed	Protected	Size */
/*                                                                                   */
/*  OEM_volatile_init_FastRam_8bit			Yes			Fast	No			8	 */
/*  OEM_volatile_init_SlowRam_8bit			Yes			Slow	No			8	 */
/*                                                                                   */
/*  OEM_volatile_init_FastRam_16bit			Yes			Fast	No			16 	 */
/*  OEM_volatile_init_SlowRam_16bit			Yes			Slow	No			16 	 */
/*                                                                                   */
/*  OEM_volatile_init_FastRam_32bit			Yes			Fast	No			32 	 */
/*  OEM_volatile_init_SlowRam_32bit			Yes			Slow	No			32 	 */
/*                                                                                   */
/*  OEM_volatile_bit_init_fast			    Yes			Fast	No			1 	 */
/*  OEM_volatile_bit_init_slow			    Yes			Slow	No			8 	 */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/

/*************************************************************************************/
/*   Memory: volatile_init, Fast, 8bits                                              */
/*   Pragma: OEM_volatile_init_FastRam_8bit                                       */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_init_FastRam_8bit
    #pragma section .zdata.OEM.a1 awz
    #undef START_SECTION_OEM_volatile_init_FastRam_8bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_init_FastRam_8bit
    #pragma section
    #undef STOP_SECTION_OEM_volatile_init_FastRam_8bit
    #undef PRAGMA_UNUSED
#endif


/*************************************************************************************/
/*   Memory: volatile_init, Slow, 8bits                                              */
/*   Pragma: OEM_volatile_init_SlowRam_8bit                                       */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_init_SlowRam_8bit
    #pragma section .data.OEM.a1 aw
    #undef START_SECTION_OEM_volatile_init_SlowRam_8bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_init_SlowRam_8bit
    #pragma section
    #undef STOP_SECTION_OEM_volatile_init_SlowRam_8bit
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Memory: volatile_init, Fast, 16bits                                             */
/*   Pragma: OEM_volatile_init_FastRam_16bit                                      */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_init_FastRam_16bit
    #pragma section .zdata.OEM.a2 awz
    #undef START_SECTION_OEM_volatile_init_FastRam_16bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_init_FastRam_16bit
    #pragma section
    #undef STOP_SECTION_OEM_volatile_init_FastRam_16bit
    #undef PRAGMA_UNUSED
#endif


/*************************************************************************************/
/*   Memory: volatile_init, Slow, 16bits                                             */
/*   Pragma: OEM_volatile_init_SlowRam_16bit                                      */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_init_SlowRam_16bit
    #pragma section .data.OEM.a2 aw
    #undef START_SECTION_OEM_volatile_init_SlowRam_16bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_init_SlowRam_16bit
    #pragma section
    #undef STOP_SECTION_OEM_volatile_init_SlowRam_16bit
    #undef PRAGMA_UNUSED
#endif


/*************************************************************************************/
/*   Memory: volatile_init, Fast, 32bits                                             */
/*   Pragma: OEM_volatile_init_FastRam_32bit                                      */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_init_FastRam_32bit
    #pragma section .sdata.OEM.a4 aws
    #undef START_SECTION_OEM_volatile_init_FastRam_32bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_init_FastRam_32bit
    #pragma section
    #undef STOP_SECTION_OEM_volatile_init_FastRam_32bit
    #undef PRAGMA_UNUSED
#endif


/*************************************************************************************/
/*   Memory: volatile_init, Slow, 32bits                                             */
/*   Pragma: OEM_volatile_init_SlowRam_32bit                                      */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_init_SlowRam_32bit
    #pragma section .data.OEM.a4 aw
    #undef START_SECTION_OEM_volatile_init_SlowRam_32bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_init_SlowRam_32bit
    #pragma section
    #undef STOP_SECTION_OEM_volatile_init_SlowRam_32bit
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Memory: volatile_bit_init, Fast, 1bit                                           */
/*   Pragma: OEM_volatile_bit_init_fast                                       */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_bit_init_fast
    #pragma section .bdata.OEM awbz
    #undef START_SECTION_OEM_volatile_bit_init_fast
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_bit_init_fast
    #pragma section
    #undef STOP_SECTION_OEM_volatile_bit_init_fast
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Memory: volatile_bit_init, Slow, 8bits                                          */
/*   Pragma: OEM_volatile_bit_init_slow                                       */
/*************************************************************************************/

#ifdef START_SECTION_OEM_volatile_bit_init_slow
    #pragma section .data.OEM.a1 aw
    #undef START_SECTION_OEM_volatile_bit_init_slow
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_volatile_bit_init_slow
    #pragma section
    #undef STOP_SECTION_OEM_volatile_bit_init_slow
    #undef PRAGMA_UNUSED
#endif


/*************************************************************************************/
/*                Pragmas for static variables and structures                        */
/*        ====================================================================       */
/*                                                                                   */
/*  								Memory location     							 */
/*                                                                                   */
/*					Official pragma supported by the Plattform						 */
/*                                                                                   */
/*	Section's name								Volatile	Speed	Protected	Size */
/*                                                                                   */
/*  OEM_nonvolatile_Ram_8bit		        No			-	No			8	 */
/*                                                                                   */
/*  OEM_nonvolatile_Ram_16bit			No			-	No			16 	 */
/*                                                                                   */
/*  OEM_nonvolatile_Ram_32bit			No			-	No			32 	 */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/


/*************************************************************************************/
/*   Memory: NonVolatile, , 8bits                                                */
/*   Pragma: OEM_nonvolatile_Ram_8bit                                         */
/*************************************************************************************/

#ifdef START_SECTION_OEM_nonvolatile_Ram_8bit
    #pragma section .bss.OEM_envram.a1 aw
    #undef START_SECTION_OEM_nonvolatile_Ram_8bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_nonvolatile_Ram_8bit
    #pragma section
    #undef STOP_SECTION_OEM_nonvolatile_Ram_8bit
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Memory: NonVolatile, , 16bits                                               */
/*   Pragma: OEM_nonvolatile_Ram_16bit                                        */
/*************************************************************************************/

#ifdef START_SECTION_OEM_nonvolatile_Ram_16bit
    #pragma section .bss.OEM_envram.a2 aw
    #undef START_SECTION_OEM_nonvolatile_Ram_16bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_nonvolatile_Ram_16bit
    #pragma section
    #undef STOP_SECTION_OEM_nonvolatile_Ram_16bit
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Memory: NonVolatile, , 32bits                                               */
/*   Pragma: OEM_nonvolatile_Ram_32bit                                        */
/*************************************************************************************/

#ifdef START_SECTION_OEM_nonvolatile_Ram_32bit
    #pragma section .bss.OEM_envram.a4 aw
    #undef START_SECTION_OEM_nonvolatile_Ram_32bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_nonvolatile_Ram_32bit
    #pragma section
    #undef STOP_SECTION_OEM_nonvolatile_Ram_32bit
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*                Pragmas for static variables and structures                        */
/*        ====================================================================       */
/*                                                                                   */
/*  								Memory location     							 */
/*                                                                                   */
/*					Official pragma supported by the Plattform						 */
/*                                                                                   */
/*	Section's name								Volatile	Speed	Protected	Size */
/*                                                                                   */
/*  OEM_Caldata_8bit		        No			-	No			8	 */
/*                                                                                   */
/*  OEM_Caldata_16bit			No			-	No			16 	 */
/*                                                                                   */
/*  OEM_Caldata_32bit			No			-	No			32 	 */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/


/*************************************************************************************/
/*   Memory: calibration values, 32bits                                              */
/*   Pragma: OEM_Caldata_32bit                                                         */
/*************************************************************************************/

#ifdef START_SECTION_OEM_Caldata_32bit
    #pragma section .caldata.OEM_userData32 a
    #undef START_SECTION_OEM_Caldata_32bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_Caldata_32bit
    #pragma section
    #undef STOP_SECTION_OEM_Caldata_32bit
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Memory: calibration values , 16bits                                             */
/*   Pragma: OEM_Caldata_16bit                                                         */
/*************************************************************************************/

#ifdef START_SECTION_OEM_Caldata_16bit
    #pragma section .caldata.OEM_userData16 a
    #undef START_SECTION_OEM_Caldata_16bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_Caldata_16bit
    #pragma section
    #undef STOP_SECTION_OEM_Caldata_16bit
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Memory: calibration values  8bits                                               */
/*   Pragma:  OEM_Caldata_8bit                                                         */
/*************************************************************************************/

#ifdef START_SECTION_OEM_Caldata_8bit
    #pragma section .caldata.OEM_userData8 a
    #undef START_SECTION_OEM_Caldata_8bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_Caldata_8bit
    #pragma section
    #undef STOP_SECTION_OEM_Caldata_8bit
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*                Pragmas for static variables and structures                        */
/*        ====================================================================       */
/*                                                                                   */
/*  								Memory location     							 */
/*                                                                                   */
/*					Official pragma supported by the Plattform						 */
/*                                                                                   */
/*	Section's name								Volatile	Speed	Protected	Size */
/*                                                                                   */
/*  OEM_Const_8bit		        No			-	No			8	 */
/*                                                                                   */
/*  OEM_Const_16bit			No			-	No			16 	 */
/*                                                                                   */
/*  OEM_Const_32bit			No			-	No			32 	 */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/

/*************************************************************************************/
/*   Memory: Constant 32 bit                                                         */
/*   Pragma:  OEM_Const_32bit                                                       */
/*************************************************************************************/

#ifdef START_SECTION_OEM_Const_32bit
    #pragma section .rodata.OEM_ConstData32.a4 a
    #undef START_SECTION_OEM_Const_32bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_Const_32bit
    #pragma section
    #undef STOP_SECTION_OEM_Const_32bit
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Memory: Constant 16 bit                                                         */
/*   Pragma:  OEM_Const_16bit                                                       */
/*************************************************************************************/

#ifdef START_SECTION_OEM_Const_16bit
    #pragma section .rodata.OEM_ConstData16.a2 a
    #undef START_SECTION_OEM_Const_16bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_Const_16bit
    #pragma section
    #undef STOP_SECTION_OEM_Const_16bit
    #undef PRAGMA_UNUSED
#endif

/*************************************************************************************/
/*   Memory: Constant 8 bit                                                          */
/*   Pragma:  OEM_Const_8bit                                                        */
/*************************************************************************************/

#ifdef START_SECTION_OEM_Const_8bit
    #pragma section .rodata.OEM_ConstData8.a1 a
    #undef START_SECTION_OEM_Const_8bit
    #undef PRAGMA_UNUSED
#endif

#ifdef STOP_SECTION_OEM_Const_8bit
    #pragma section
    #undef STOP_SECTION_OEM_Const_8bit
    #undef PRAGMA_UNUSED
#endif



/****************************************************************************************/
/*                                                                                      */
/*                       Test: does the required Pragma exist ?                         */
/*                                                                                      */
/****************************************************************************************/

#ifdef PRAGMA_UNUSED
    #error "Error: The file swsh_uaes2oem.h has been included, but no pragma was found"
#endif


/*************************************************************************************/
/*                                                                                   */
/*                                                End of file                        */
/*                                                                                   */
/*************************************************************************************/
