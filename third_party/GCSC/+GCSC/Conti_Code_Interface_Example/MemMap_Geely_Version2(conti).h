#ifndef _MEMMAP_GEELY_H_
#define _MEMMAP_GEELY_H_

#if defined START_SEC_CODE_RESET
   #undef START_SEC_CODE_RESET
   #define MEM_OEM MEM_OEM_CODE_SEG
   #include "MemMap_OEM.h"
   
#elif defined STOP_SEC_CODE_RESET
   #undef STOP_SEC_CODE_RESET
   
#elif defined START_SEC_CODE_SYNC
   #undef START_SEC_CODE_SYNC
   #define MEM_OEM MEM_OEM_CODE_SEG
   #include "MemMap_OEM.h"
   
#elif defined STOP_SEC_CODE_SYNC
   #undef STOP_SEC_CODE_SYNC   

#elif defined START_SEC_CODE_10MS
   #undef START_SEC_CODE_10MS
   #define MEM_OEM MEM_OEM_CODE_10MS
   #include "MemMap_OEM.h"
   
#elif defined STOP_SEC_CODE_10MS
   #undef STOP_SEC_CODE_10MS  
   
#elif defined START_SEC_CODE_20MS
   #undef START_SEC_CODE_20MS
   #define MEM_OEM MEM_OEM_CODE_20MS
   #include "MemMap_OEM.h"
   
#elif defined STOP_SEC_CODE_20MS
   #undef STOP_SEC_CODE_20MS    

#elif defined START_SEC_CODE_50MS
   #undef START_SEC_CODE_50MS
   #define MEM_OEM MEM_OEM_CODE_40MS
   #include "MemMap_OEM.h"
   
#elif defined STOP_SEC_CODE_50MS
   #undef STOP_SEC_CODE_50MS

#elif defined START_SEC_CODE_100MS
   #undef START_SEC_CODE_100MS
   #define MEM_OEM MEM_OEM_CODE_100MS
   #include "MemMap_OEM.h"
   
#elif defined STOP_SEC_CODE_100MS
   #undef STOP_SEC_CODE_100MS

#elif defined START_SEC_CODE_200MS
   #undef START_SEC_CODE_200MS
   #define MEM_OEM MEM_OEM_CODE_SLOW
   #include "MemMap_OEM.h"
   
#elif defined STOP_SEC_CODE_200MS
   #undef STOP_SEC_CODE_200MS

#elif defined START_SEC_CODE_1000MS
   #undef START_SEC_CODE_1000MS
   #define MEM_OEM MEM_OEM_CODE_SLOW
   #include "MemMap_OEM.h"
   
#elif defined STOP_SEC_CODE_1000MS
   #undef STOP_SEC_CODE_1000MS
   
#elif defined START_SEC_CALIB_32BIT
   #undef START_SEC_CALIB_32BIT
   #define MEM_OEM MEM_OEM_CAL
   #define GMEM_MODE__CAL__OEM_32
   #include "MemMap_OEM.h"
   #undef GMEM_MODE__CAL__OEM_32
   
#elif defined STOP_SEC_CALIB_32BIT
   #undef STOP_SEC_CALIB_32BIT

#elif defined START_SEC_CALIB_16BIT
   #undef START_SEC_CALIB_16BIT
   #define MEM_OEM MEM_OEM_CAL
   #define GMEM_MODE__CAL__OEM_16
   #include "MemMap_OEM.h"
   #undef GMEM_MODE__CAL__OEM_16
   
#elif defined STOP_SEC_CALIB_16BIT
   #undef STOP_SEC_CALIB_16BIT  
   
#elif defined START_SEC_CALIB_8BIT
   #undef START_SEC_CALIB_8BIT
   #define MEM_OEM MEM_OEM_CAL
   #define GMEM_MODE__CAL__OEM_08
   #include "MemMap_OEM.h"
   #undef GMEM_MODE__CAL__OEM_08
   
#elif defined STOP_SEC_CALIB_8BIT
   #undef STOP_SEC_CALIB_8BIT

#elif defined START_SEC_CALIB_BOOLEAN
   #undef START_SEC_CALIB_BOOLEAN
   #define MEM_OEM MEM_OEM_CAL
   #define GMEM_MODE__CAL__OEM_08 
   #include "MemMap_OEM.h"
   #undef GMEM_MODE__CAL__OEM_08

#elif defined STOP_SEC_CALIB_BOOLEAN
   #undef STOP_SEC_CALIB_BOOLEAN  

#elif defined START_SEC_VAR_volatile_FastRam_32BIT
   #undef START_SEC_VAR_volatile_FastRam_32BIT
   #define MEM_OEM MEM_OEM_DATA_PUBLIC_32
   #include "MemMap_OEM.h"
   
#elif defined STOP_SEC_VAR_volatile_FastRam_32BIT
   #undef STOP_SEC_VAR_volatile_FastRam_32BIT   
   
#elif defined START_SEC_VAR_volatile_FastRam_16BIT
   #undef START_SEC_VAR_volatile_FastRam_16BIT
   #define MEM_OEM MEM_OEM_DATA_PUBLIC_16
   #include "MemMap_OEM.h"
   
#elif defined STOP_SEC_VAR_volatile_FastRam_16BIT
   #undef STOP_SEC_VAR_volatile_FastRam_16BIT
   
#elif defined START_SEC_VAR_volatile_FastRam_8BIT
   #undef START_SEC_VAR_volatile_FastRam_8BIT
   #define MEM_OEM MEM_OEM_DATA_PUBLIC_8
   #include "MemMap_OEM.h"

#elif defined STOP_SEC_VAR_volatile_FastRam_8BIT
   #undef STOP_SEC_VAR_volatile_FastRam_8BIT
  
#elif defined START_SEC_VAR_volatile_FastRam_BOOLEAN
   #undef START_SEC_VAR_volatile_FastRam_BOOLEAN
   #define MEM_OEM MEM_OEM_DATA_PUBLIC_FLAG
   #include "MemMap_OEM.h"
   
#elif defined STOP_SEC_VAR_volatile_FastRam_BOOLEAN
   #undef STOP_SEC_VAR_volatile_FastRam_BOOLEAN

#elif defined START_SEC_VAR_volatile_SlowRam_32BIT
   #undef START_SEC_VAR_volatile_SlowRam_32BIT
   #define MEM_OEM MEM_OEM_DATA_PRIVATE_32
   #include "MemMap_OEM.h"

#elif defined STOP_SEC_VAR_volatile_SlowRam_32BIT
   #undef STOP_SEC_VAR_volatile_SlowRam_32BIT   

#elif defined START_SEC_VAR_volatile_SlowRam_16BIT
   #undef START_SEC_VAR_volatile_SlowRam_16BIT
   #define MEM_OEM MEM_OEM_DATA_PRIVATE_16
   #include "MemMap_OEM.h"

#elif defined STOP_SEC_VAR_volatile_SlowRam_16BIT
   #undef STOP_SEC_VAR_volatile_SlowRam_16BIT
   
#elif defined START_SEC_VAR_volatile_SlowRam_8BIT
   #undef START_SEC_VAR_volatile_SlowRam_8BIT
   #define MEM_OEM MEM_OEM_DATA_PRIVATE_8
   #include "MemMap_OEM.h"

#elif defined STOP_SEC_VAR_volatile_SlowRam_8BIT
   #undef STOP_SEC_VAR_volatile_SlowRam_8BIT

#elif defined START_SEC_CONST_32BIT
   #undef START_SEC_CONST_32BIT
   #define MEM_OEM MEM_OEM_CONST  
   #include "MemMap_OEM.h"   
   
#elif defined STOP_SEC_CONST_32BIT
   #undef STOP_SEC_CONST_32BIT

#elif defined START_SEC_CONST_16BIT
   #undef START_SEC_CONST_16BIT
   #define MEM_OEM MEM_OEM_CONST  
   #include "MemMap_OEM.h"   
   
#elif defined STOP_SEC_CONST_16BIT
   #undef STOP_SEC_CONST_16BIT 

#elif defined START_SEC_CONST_8BIT
   #undef START_SEC_CONST_8BIT
   #define MEM_OEM MEM_OEM_CONST  
   #include "MemMap_OEM.h"   
   
#elif defined STOP_SEC_CONST_8BIT
   #undef STOP_SEC_CONST_8BIT

#else
   #error "MemMap_Geely.h was included without valid memory section define!"
#endif   
   
#endif /* _MEMMAP_GEELY_H_ */
#undef _MEMMAP_GEELY_H_