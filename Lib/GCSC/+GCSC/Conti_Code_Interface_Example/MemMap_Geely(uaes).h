#ifndef _MEMMAP_GEELY_H_
#define _MEMMAP_GEELY_H_

#if defined START_SEC_VAR_volatile_FastRam_32BIT
   #undef START_SEC_VAR_volatile_FastRam_32BIT
   #define START_SECTION_OEM_volatile_FastRam_32bit

#elif defined STOP_SEC_VAR_volatile_FastRam_32BIT
   #undef STOP_SEC_VAR_volatile_FastRam_32BIT
   #define STOP_SECTION_OEM_volatile_FastRam_32bit
   
#elif defined START_SEC_VAR_volatile_FastRam_16BIT
   #undef START_SEC_VAR_volatile_FastRam_16BIT
   #define START_SECTION_OEM_volatile_FastRam_16bit
   
#elif defined STOP_SEC_VAR_volatile_FastRam_16BIT
   #undef STOP_SEC_VAR_volatile_FastRam_16BIT
   #define STOP_SECTION_OEM_volatile_FastRam_16bit
   
#elif defined START_SEC_VAR_volatile_FastRam_8BIT
   #undef START_SEC_VAR_volatile_FastRam_8BIT
   #define START_SECTION_OEM_volatile_FastRam_8bit

#elif defined STOP_SEC_VAR_volatile_FastRam_8BIT
   #undef STOP_SEC_VAR_volatile_FastRam_8BIT
   #define STOP_SECTION_OEM_volatile_FastRam_8bit
  
#elif defined START_SEC_VAR_volatile_FastRam_BOOLEAN
   #undef START_SEC_VAR_volatile_FastRam_BOOLEAN
   #define START_SECTION_OEM_volatile_FastRam_8bit
   
#elif defined STOP_SEC_VAR_volatile_FastRam_BOOLEAN
   #undef STOP_SEC_VAR_volatile_FastRam_BOOLEAN
   #define STOP_SECTION_OEM_volatile_FastRam_8bit
 
#elif defined START_SEC_CODE_RESET
   #undef START_SEC_CODE_RESET
   #define START_SECTION_Task_OEM_rini
   
#elif defined STOP_SEC_CODE_RESET
   #undef STOP_SEC_CODE_RESET
   #define STOP_SECTION_Task_OEM_rini
     
#elif defined START_SEC_CODE_10MS
   #undef START_SEC_CODE_10MS
   #define START_SECTION_Task_OEM_r10ms

#elif defined STOP_SEC_CODE_10MS
   #undef STOP_SEC_CODE_10MS
   #define STOP_SECTION_Task_OEM_r10ms  
   
#elif defined START_SEC_CODE_50MS
   #undef START_SEC_CODE_50MS
   #define START_SECTION_Task_OEM_r50ms

#elif defined STOP_SEC_CODE_50MS
   #undef STOP_SEC_CODE_50MS
   #define STOP_SECTION_Task_OEM_r50ms

#elif defined START_SEC_CODE_100MS
   #undef START_SEC_CODE_100MS
   #define START_SECTION_Task_OEM_r100ms

#elif defined STOP_SEC_CODE_100MS
   #undef STOP_SEC_CODE_100MS
   #define STOP_SECTION_Task_OEM_r100ms 
   
#elif defined START_SEC_CALIB_32BIT
   #undef START_SEC_CALIB_32BIT
   #define START_SECTION_OEM_Caldata_32bit
   
#elif defined STOP_SEC_CALIB_32BIT
   #undef STOP_SEC_CALIB_32BIT
   #define STOP_SECTION_OEM_Caldata_32bit   
 
#elif defined START_SEC_CALIB_16BIT
   #undef START_SEC_CALIB_16BIT
   #define START_SECTION_OEM_Caldata_16bit
   
#elif defined STOP_SEC_CALIB_16BIT
   #undef STOP_SEC_CALIB_16BIT  
   #define STOP_SECTION_OEM_Caldata_16bit
   
#elif defined START_SEC_CALIB_8BIT
   #undef START_SEC_CALIB_8BIT
   #define START_SECTION_OEM_Caldata_8bit
   
#elif defined STOP_SEC_CALIB_8BIT
   #undef STOP_SEC_CALIB_8BIT
   #define STOP_SECTION_OEM_Caldata_8bit

#elif defined START_SEC_CALIB_BOOLEAN
   #undef START_SEC_CALIB_BOOLEAN
   #define START_SECTION_OEM_Caldata_8bit

#elif defined STOP_SEC_CALIB_BOOLEAN
   #undef STOP_SEC_CALIB_BOOLEAN  
   #define STOP_SECTION_OEM_Caldata_8bit

#elif defined START_SEC_CONST_32BIT
   #undef START_SEC_CONST_32BIT
   #define START_SECTION_OEM_Const_32bit
   
#elif defined STOP_SEC_CONST_32BIT
   #undef STOP_SEC_CONST_32BIT  
   #define STOP_SECTION_OEM_Const_32bit   
   
#elif defined START_SEC_VAR_nonvolatile_Ram_32BIT
   #undef START_SEC_VAR_nonvolatile_Ram_32BIT  
   #define START_SECTION_OEM_nonvolatile_Ram_32bit   

#elif defined STOP_SEC_VAR_nonvolatile_Ram_32BIT
   #undef STOP_SEC_VAR_nonvolatile_Ram_32BIT  
   #define STOP_SECTION_OEM_nonvolatile_Ram_32bit 

#elif defined START_SEC_VAR_nonvolatile_Ram_16BIT
   #undef START_SEC_VAR_nonvolatile_Ram_16BIT
   #define START_SECTION_OEM_nonvolatile_Ram_16bit   

#elif defined STOP_SEC_VAR_nonvolatile_Ram_16BIT
   #undef STOP_SEC_VAR_nonvolatile_Ram_16BIT  
   #define STOP_SECTION_OEM_nonvolatile_Ram_16bit 

#elif defined START_SEC_VAR_nonvolatile_Ram_8BIT
   #undef START_SEC_VAR_nonvolatile_Ram_8BIT  
   #define START_SECTION_OEM_nonvolatile_Ram_8bit   

#elif defined STOP_SEC_VAR_nonvolatile_Ram_8BIT
   #undef STOP_SEC_VAR_nonvolatile_Ram_8BIT  
   #define STOP_SECTION_OEM_nonvolatile_Ram_8bit   

#else
   #define PRAGMA_UNUSED
#endif

#ifndef PRAGMA_UNUSED
#include "swsh_uaes2oem.h"
#endif

#ifdef PRAGMA_UNUSED
   #error "MemMap_Geely.h was included without valid memory section define!"
#endif

#endif /* _MEMMAP_GEELY_H_ */
#undef _MEMMAP_GEELY_H_

