
 /*
 * File: Zeekr_MemMap.h
 *
 *
 * Project                        : PCMU
 * Version                        : 1.0.0
 * Reversion                      : 0
 * Description                    : Change section for CAL
 * LastModifiedBy                 : huwentao
 * ChangeData                     : 2022-03-1
 */


#ifndef _ZEEKR_MEMMAP_H_
#define _ZEEKR_MEMMAP_H_
   

  
#if defined START_SEC_CAL_8BIT_UNSPECIFIED
   #undef START_SEC_CAL_8BIT_UNSPECIFIED
   #define START_CAL_CONST
#include <MemMap_Cal.h>

#elif defined START_SEC_CAL_8BIT_UNSPECIFIED_ASILAB
   #undef START_SEC_CAL_8BIT_UNSPECIFIED_ASILAB
   #define START_CAL_CONST
#include <MemMap_Cal.h>

#elif defined START_SEC_CAL_8BIT_UNSPECIFIED_ASILC
   #undef START_SEC_CAL_8BIT_UNSPECIFIED_ASILC
   #define START_CAL_CONST
#include <MemMap_Cal.h>

#elif defined START_SEC_CAL_16BIT_UNSPECIFIED
   #undef START_SEC_CAL_16BIT_UNSPECIFIED
   #define START_CAL_CONST
#include <MemMap_Cal.h> 

#elif defined START_SEC_CAL_16BIT_UNSPECIFIED_ASILAB
   #undef START_SEC_CAL_16BIT_UNSPECIFIED_ASILAB
   #define START_CAL_CONST
#include <MemMap_Cal.h> 

#elif defined START_SEC_CAL_16BIT_UNSPECIFIED_ASILC
   #undef START_SEC_CAL_16BIT_UNSPECIFIED_ASILC
   #define START_CAL_CONST
#include <MemMap_Cal.h> 

#elif defined START_SEC_CAL_32BIT_UNSPECIFIED
   #undef START_SEC_CAL_32BIT_UNSPECIFIED
   #define START_CAL_CONST
#include <MemMap_Cal.h>

#elif defined START_SEC_CAL_32BIT_UNSPECIFIED_ASILAB
   #undef START_SEC_CAL_32BIT_UNSPECIFIED_ASILAB
   #define START_CAL_CONST
#include <MemMap_Cal.h>

#elif defined START_SEC_CAL_32BIT_UNSPECIFIED_ASILC
   #undef START_SEC_CAL_32BIT_UNSPECIFIED_ASILC
   #define START_CAL_CONST
#include <MemMap_Cal.h>

#elif defined STOP_SEC_CAL_8BIT_UNSPECIFIED
#undef STOP_SEC_CAL_8BIT_UNSPECIFIED
#define STOP_CAL_CONST
#include <MemMap_Cal.h> 

#elif defined STOP_SEC_CAL_8BIT_UNSPECIFIED_ASILAB
#undef STOP_SEC_CAL_8BIT_UNSPECIFIED_ASILAB
#define STOP_CAL_CONST
#include <MemMap_Cal.h> 

#elif defined STOP_SEC_CAL_8BIT_UNSPECIFIED_ASILC
#undef STOP_SEC_CAL_8BIT_UNSPECIFIED_ASILC
#define STOP_CAL_CONST
#include <MemMap_Cal.h> 

#elif defined STOP_SEC_CAL_16BIT_UNSPECIFIED
   #undef STOP_SEC_CAL_16BIT_UNSPECIFIED
   #define STOP_CAL_CONST
#include <MemMap_Cal.h> 

#elif defined STOP_SEC_CAL_16BIT_UNSPECIFIED_ASILAB
   #undef STOP_SEC_CAL_16BIT_UNSPECIFIED_ASILAB
   #define STOP_CAL_CONST
#include <MemMap_Cal.h> 

#elif defined STOP_SEC_CAL_16BIT_UNSPECIFIED_ASILC
   #undef STOP_SEC_CAL_16BIT_UNSPECIFIED_ASILC
   #define STOP_CAL_CONST
#include <MemMap_Cal.h> 
     
#elif defined STOP_SEC_CAL_32BIT_UNSPECIFIED
   #undef STOP_SEC_CAL_32BIT_UNSPECIFIED
   #define STOP_CAL_CONST
#include <MemMap_Cal.h>

#elif defined STOP_SEC_CAL_32BIT_UNSPECIFIED_ASILAB
   #undef STOP_SEC_CAL_32BIT_UNSPECIFIED_ASILAB
   #define STOP_CAL_CONST
#include <MemMap_Cal.h>

#elif defined STOP_SEC_CAL_32BIT_UNSPECIFIED_ASILC
   #undef STOP_SEC_CAL_32BIT_UNSPECIFIED_ASILC
   #define STOP_CAL_CONST
#include <MemMap_Cal.h>

#else
   #error "Zeekr_memap.h was included without valid memory section define!"
#endif   
   
#endif 
#undef _ZEEKR_MEMMAP_H_
