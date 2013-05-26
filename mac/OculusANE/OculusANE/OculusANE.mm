//
//  OculusANE.m
//  OculusANE
//
//  Created by Jonathan on 5/26/13.
//  Copyright (c) 2013 Numeda. All rights reserved.
//

#import "OculusANE.h"
#include <Adobe AIR/Adobe Air.h>

#include "OVR.h"
#include "Kernel/OVR_String.h"

using namespace OVR;

extern "C" {
    void OculusANE_ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet){
        
        int functions = 4;
        
        *numFunctionsToSet = functions;
        
        FRENamedFunction* func = (FRENamedFunction*)malloc(sizeof(FRENamedFunction)* functions);
        
        func[0].name = (const uint8_t*)"getHMDDeviceList";
        func[0].functionData = NULL;
        func[0].function = &getHMDDeviceList;
        
        func[3].name = (const uint8_t*)"isSupported";
        func[3].functionData = NULL;
        func[3].function = &isSupported;
        
        *functionsToSet = func;
    }
    
    void OculusANE_ContextFinalizer(FREContext ctx)
    {
//        NSLog(@"FINALIZING");
//       NSLog(@"%@",[NSThread callStackSymbols]);
        return;
    }
    
    void OculusANEInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet){
        extDataToSet = NULL;
        *ctxInitializerToSet = &OculusANE_ContextInitializer;
        *ctxFinalizerToSet = &OculusANE_ContextFinalizer;
//        redirectConsoleLogToDocumentFolder();
    }
    
    void OculusANEFinalizer (FREContext ctx) {
    }

}