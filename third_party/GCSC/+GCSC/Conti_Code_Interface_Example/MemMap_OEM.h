/*~-*/
/*~XSF_LANGUAGE: C/C++*/
/*~A*/
/*~+:Module Header*/
/*~T*/
/****************************************************************************
 * COPYRIGHT (C) CONTINENTAL AUTOMOTIVE GMBH
 * ALL RIGHTS RESERVED.
 *
 * The reproduction, transmission or use of this document or its
 * contents is not permitted without express written authority.
 * Offenders will be liable for damages. All rights, including rights
 * created by patent grant or registration of a utility model or design,
 * are reserved.
 *---------------------------------------------------------------------------
 * Purpose:    Memory Allocation Environment - OEM
 *
 * Spec.ref.:  SwArch Specification Memory Allocation
 *
 * Processor:  MPC555
 * Tool chain: DiabData
 * Filename:   $Workfile:   MemMap_OEM.h  $
 * Revision:   $Revision:   0.1  $
 * Author:     $Author:   uidq6334  $
 * Date:       $Date:   May 23 2016 09:42:42  $

 ****************************************************************************/

/*~E*/
/*~K*/
/*~+:Memory Allocation Environment - OEM*/
/*~I*/
#ifndef MEMMAP_OEM_H

/*~T*/
#define MEMMAP_OEM_H

/*~A*/
/*~+:Create memory class identifiers*/
/*~T*/
    #define MEM_OEM_CODE_SEG               (0x01)    /* segment synchronous */
    #define MEM_OEM_CODE_1MS               (0x02)    /* 1MS recurrency */
    #define MEM_OEM_CODE_5MS               (0x03)    /* 5MS recurrency */
    #define MEM_OEM_CODE_10MS              (0x04)    /* 10MS recurrency */
    #define MEM_OEM_CODE_20MS              (0x05)    /* 20MS recurrency */
    #define MEM_OEM_CODE_40MS              (0x06)    /* 40MS recurrency */
    #define MEM_OEM_CODE_100MS             (0x07)    /* 100MS recurrency */
    #define MEM_OEM_CODE_SLOW              (0x0A)    /* SLOW without fix recurrence */
    #define MEM_OEM_CODE_ECM2_10MS         (0x0B)    /* ECM2 10MS recurrency */
    #define MEM_OEM_CODE_ECM2_NORM         (0x0C)    /* ECM2 normaloperation with fix recurrence */
    #define MEM_OEM_CODE_ECM2_SLOW         (0x0D)    /* ECM2 SLOW without fix recurrence */

/*~T*/
    #define MEM_OEM_DATA_PUBLIC_FLAG       (0x10)    /* byte aligned public flags */
    #define MEM_OEM_DATA_PUBLIC_8          (0x11)    /* byte aligned public */
    #define MEM_OEM_DATA_PUBLIC_16         (0x12)    /* word aligned public */
    #define MEM_OEM_DATA_PUBLIC_32         (0x13)    /* long aligned public u32, s32, float*/
    #define MEM_OEM_DATA_PUBLIC_64         (0x14)    /* long aligned public u64, s64, double*/
    #define MEM_OEM_DATA_PUBLIC_POINTER    (0x15)    /* long aligned public pointer types */

    #define MEM_OEM_DATA_PRIVATE_FLAG      (0x20)    /* byte aligned private flags */
    #define MEM_OEM_DATA_PRIVATE_8         (0x21)    /* byte aligned private */
    #define MEM_OEM_DATA_PRIVATE_16        (0x22)    /* word aligned private */
    #define MEM_OEM_DATA_PRIVATE_32        (0x23)    /* long aligned private u32, s32, float*/
    #define MEM_OEM_DATA_PRIVATE_64        (0x24)    /* long aligned private u64, s64, double*/
    #define MEM_OEM_DATA_PRIVATE_POINTER   (0x25)    /* long aligned private pointer types */

    #define MEM_OEM_DATA_ECM2              (0x1A)    /* ECM2 data */

/*~T*/


/*~T*/
    #define MEM_OEM_CAL                    (0x40)    /* Calibrateable             */
    #define MEM_OEM_CAL_ECM2               (0x41)    /* Calibratable constants of ECM2-functions */

/*~T*/
    #define MEM_OEM_CONST                  (0x30)    /* Constant                  */
    #define MEM_OEM_CONST_ECM2             (0x31)    /* ECM2 constants and ECM2 code constants */
/*~E*/
/*~T*/

/*~-*/
#endif
/*~E*/
/*~A*/
/*~+:Evaluate used memory environments*/
/*~T*/
#ifdef MEM_OEM

/*~K*/
/*~+:Evaluate used memory environments */
/*~A*/
/*~+:OEM CODE*/
/*~T*/
#if  (MEM_OEM == MEM_OEM_CODE_SEG)
      #pragma section CODE      ".code_crk_seg"                                         standard
      #pragma section CONST     ".far_const_crk_seg"            ".illegal_const"        far-absolute
      #pragma section SCONST    ".far_const_crk_seg"            ".illegal_sconst"       far-absolute
      #pragma section STRING    ".far_const_crk_seg"                                    far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_CODE_1MS)
	  #pragma section CODE    	".code_faster_5ms"                             			standard
      #pragma section CONST  	".far_const_faster_5ms"         ".illegal_const"        far-absolute
      #pragma section SCONST 	".far_const_faster_5ms"         ".illegal_sconst"       far-absolute
      #pragma section STRING 	".far_const_faster_5ms"                                 far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_CODE_5MS)
	  #pragma section CODE     	".code_5ms"                                    			standard
      #pragma section CONST  	".far_const_5ms"                ".illegal_const"        far-absolute
      #pragma section SCONST 	".far_const_5ms"                ".illegal_sconst"       far-absolute
      #pragma section STRING 	".far_const_5ms"                                        far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_CODE_10MS)
	  #pragma section CODE     	".code_10ms"                                   			standard
      #pragma section CONST  	".far_const_10ms"               ".illegal_const"        far-absolute
      #pragma section SCONST 	".far_const_10ms"               ".illegal_sconst"       far-absolute
      #pragma section STRING 	".far_const_10ms"                                       far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_CODE_20MS)
      #pragma section CODE     	".code_20ms"                                   			standard
	  #pragma section CONST  	".far_const_20ms"               ".illegal_const"        far-absolute
      #pragma section SCONST 	".far_const_20ms"               ".illegal_sconst"       far-absolute
      #pragma section STRING 	".far_const_20ms"                                       far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_CODE_40MS)
	  #pragma section CODE     	".code_40ms"                                   			standard
      #pragma section CONST  	".far_const_40ms"               ".illegal_const"        far-absolute
      #pragma section SCONST 	".far_const_40ms"               ".illegal_sconst"       far-absolute
      #pragma section STRING 	".far_const_40ms"                                       far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_CODE_100MS)
	  #pragma section CODE     	".code_100ms"                                  			standard
      #pragma section CONST  	".far_const_100ms"              ".illegal_const"        far-absolute
      #pragma section SCONST 	".far_const_100ms"              ".illegal_sconst"       far-absolute
      #pragma section STRING 	".far_const_100ms"                                      far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_CODE_SLOW)
      #pragma section CODE     	".code_slow"                                   			standard
 	  #pragma section CONST  	".far_const_slow"               ".illegal_const"        far-absolute
      #pragma section SCONST 	".far_const_slow"               ".illegal_sconst"       far-absolute
      #pragma section STRING 	".far_const_slow"                                       far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_CODE_ECM2_10MS)
      #pragma section CODE     	".code_ecm2_10ms_partly"                       			standard
      #pragma section CONST  	".far_const_ecm2_10ms_partly"   ".illegal_const"        far-absolute
      #pragma section SCONST 	".far_const_ecm2_10ms_partly"   ".illegal_sconst"       far-absolute
      #pragma section STRING 	".far_const_ecm2_10ms_partly"                           far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_CODE_ECM2_NORM)
	  #pragma section CODE     	".code_ecm2_service"                           			standard
      #pragma section CONST  	".far_const_ecm2_service"       ".illegal_const"        far-absolute
      #pragma section SCONST 	".far_const_ecm2_service"       ".illegal_sconst"       far-absolute
      #pragma section STRING 	".far_const_ecm2_service"                               far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_CODE_ECM2_SLOW)
      #pragma section CODE     	".code_ecm2_slow"                              			standard
      #pragma section CONST  	".far_const_ecm2_slow"          ".illegal_const"        far-absolute
      #pragma section SCONST 	".far_const_ecm2_slow"          ".illegal_sconst"       far-absolute
      #pragma section STRING 	".far_const_ecm2_slow"                                  far-absolute

/*~E*/
/*~A*/
/*~+:OEM VARIABLE*/
/*~T*/
#elif (MEM_OEM == MEM_OEM_DATA_PUBLIC_FLAG)
    #pragma section DATA  ".far_data_public_flag"         ".far_bss_public_flag"          far-absolute
    #pragma section SDATA ".far_data_public_flag"         ".far_bss_public_flag"          far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_DATA_PUBLIC_8)
    #pragma section DATA  ".far_data_public_8"            ".far_bss_public_8"             far-absolute
    #pragma section SDATA ".far_data_public_8"            ".far_bss_public_8"             far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_DATA_PUBLIC_16)
    #pragma section DATA  ".far_data_public_16"           ".far_bss_public_16"            far-absolute
    #pragma section SDATA ".far_data_public_16"           ".far_bss_public_16"            far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_DATA_PUBLIC_32)
    #pragma section DATA  ".far_data_public_32"           ".far_bss_public_32"            far-absolute
    #pragma section SDATA ".far_data_public_32"           ".far_bss_public_32"            far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_DATA_PUBLIC_64)
    #pragma section DATA  ".far_data_public_64"           ".far_bss_public_64"            far-absolute
    #pragma section SDATA ".far_data_public_64"           ".far_bss_public_64"            far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_DATA_PUBLIC_POINTER)
    #pragma section DATA  ".far_data_public_pointer"      ".far_bss_public_pointer"       far-absolute
    #pragma section SDATA ".far_data_public_pointer"      ".far_bss_public_pointer"       far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_DATA_PRIVATE_FLAG)
    #pragma section DATA  ".far_data_private_flag"        ".far_bss_private_flag"         far-absolute
    #pragma section SDATA ".far_data_private_flag"        ".far_bss_private_flag"         far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_DATA_PRIVATE_8)
    #pragma section DATA  ".far_data_private_8"           ".far_bss_private_8"            far-absolute
    #pragma section SDATA ".far_data_private_8"           ".far_bss_private_8"            far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_DATA_PRIVATE_16)
    #pragma section DATA  ".far_data_private_16"          ".far_bss_private_16"           far-absolute
    #pragma section SDATA ".far_data_private_16"          ".far_bss_private_16"           far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_DATA_PRIVATE_32)
    #pragma section DATA  ".far_data_private_32"          ".far_bss_private_32"           far-absolute
    #pragma section SDATA ".far_data_private_32"          ".far_bss_private_32"           far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_DATA_PRIVATE_64)
    #pragma section DATA  ".far_data_private_64"          ".far_bss_private_64"           far-absolute
    #pragma section SDATA ".far_data_private_64"          ".far_bss_private_64"           far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_DATA_PRIVATE_POINTER)
    #pragma section DATA  ".far_data_private_pointer"     ".far_bss_private_pointer"      far-absolute
    #pragma section SDATA ".far_data_private_pointer"     ".far_bss_private_pointer"      far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_DATA_ECM2)
    #pragma section DATA  ".illegal_data"                 ".far_bss_ecm2"                 far-absolute
    #pragma section SDATA ".illegal_sdata"                ".far_bss_ecm2"                 far-absolute

/*~E*/
/*~A*/
/*~+:OEM CALIBRATION*/
/*~T*/
#elif (MEM_OEM == MEM_OEM_CAL)


	#ifdef  GMEM_MODE__CAL__OEM_08)
    	#pragma option -Xsmall-const=8
	#endif
	#ifdef GMEM_MODE__CAL__OEM_16
    	#pragma option -Xsmall-const=16
	#endif
	#ifdef GMEM_MODE__CAL__OEM_32
         #pragma option -Xsmall-const=32
	#endif
	#ifdef GMEM_MODE__CAL__OEM_64
          #pragma option -Xsmall-const=64
	#endif


    #pragma section CONST    ".far_cal_const"        ".illegal_const"                 far-absolute
    #pragma section SCONST   ".sda2_cal_const"       ".illegal_sconst"                near-code
    #pragma section STRING   ".far_cal_const"                                         far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_CAL_ECM2)
	#ifdef GMEM_MODE__CAL__OEM_08
    	#pragma option -Xsmall-const=8
	#endif
	#ifdef GMEM_MODE__CAL__OEM_16
    	#pragma option -Xsmall-const=16
	#endif
	#ifdef GMEM_MODE__CAL__OEM_32
         #pragma option -Xsmall-const=32
	#endif
	#ifdef GMEM_MODE__CAL__OEM_64
          #pragma option -Xsmall-const=64
	#endif
    #pragma section CONST    ".far_cal_const_ecm2"        ".illegal_const"       far-absolute
    #pragma section SCONST   ".sda2_cal_const_ecm2"       ".illegal_sconst"      near-code
    #pragma section STRING   ".far_cal_const_ecm2"                               far-absolute

/*~E*/
/*~A*/
/*~+:OEM CONST*/
/*~T*/
#elif (MEM_OEM == MEM_OEM_CONST)
      #pragma section CONST  ".far_const_public"             ".illegal_const"          far-absolute
      #pragma section SCONST ".far_const_public"             ".illegal_sconst"         far-absolute
      #pragma section STRING ".far_const_public"                                       far-absolute

/*~T*/
#elif (MEM_OEM == MEM_OEM_CONST_ECM2)
      #pragma section CONST  ".far_const_ecm2_public"        ".illegal_const"          far-absolute
      #pragma section SCONST ".far_const_ecm2_public"        ".illegal_sconst"         far-absolute
      #pragma section STRING ".far_const_ecm2_public"                                  far-absolute

/*~E*/
/*~T*/
#else /* No memory requirement set - Default case */
      #error "GMEMOEM: Wrong or undefined memory requirement."
#endif

/*~T*/
#undef MEM_OEM                        /* clear oem environment */
#endif

/*~E*/
