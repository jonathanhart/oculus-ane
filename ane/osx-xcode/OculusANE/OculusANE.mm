//
//  OculusANE.m
//  OculusANE
//
//  Created by Jonathan on 5/26/13.
//  Copyright (c) 2013 Numeda. All rights reserved.
//

#import "OculusANE.h"
#include <Adobe AIR/Adobe Air.h>

#include "OVR_CAPI.h"
#include <string>
#include <sstream>

using namespace std;

extern "C" {
    ovrHmd hmd = NULL;
    
    void redirectConsoleLogToDocumentFolder ()
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
        freopen([logPath fileSystemRepresentation],"a+",stderr);
    }
    
    FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
        FREObject result;
        
        uint32_t isSupportedSwitch = 1;
        
        if (hmd==NULL) {
            isSupportedSwitch = 0;
        }
        
        FRENewObjectFromBool(isSupportedSwitch, &result);
        
        return result;
    }
    
    FREObject getResolution(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
    {
        FREObject resolutionResult;
        FRENewObject((const uint8_t*)"Vector.<Number>", 0, NULL, &resolutionResult, nil);
        FRESetArrayLength(&resolutionResult, 2);
        
        ovrSizei size = hmd->Resolution;

        // get an element at index
        FREObject xVal;
        double x = static_cast<double>(size.w);
        FRENewObjectFromDouble(x, &xVal);
        FRESetArrayElementAt(resolutionResult, 0, xVal);
        
        FREObject yVal;
        double y = static_cast<double>(size.h);
        FRENewObjectFromDouble(y, &yVal);
        FRESetArrayElementAt(resolutionResult, 1, yVal);
        
        return resolutionResult;
    }
    
    FREObject getCameraQuaternion(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
    {
        FREObject cameraQuaternionResult;
        FRENewObject((const uint8_t*)"Vector.<Number>", 0, NULL, &cameraQuaternionResult, nil);
        FRESetArrayLength(&cameraQuaternionResult, 4);
                
        // Query the HMD for the current tracking state.
        ovrTrackingState ts = ovrHmd_GetTrackingState(hmd, ovr_GetTimeInSeconds());
     //   if ((ovrStatus_OrientationTracked | ovrStatus_PositionTracked))
     //   {
            ovrQuatf quaternion = ts.HeadPose.ThePose.Orientation;
            
           // NSLog(@"getCameraQuaternion %f %f %f %f", quaternion.x, quaternion.y, quaternion.z, quaternion.w);
            
            // get an element at index
            FREObject xVal;
            double x = static_cast<double>(quaternion.x);
            FRENewObjectFromDouble(x, &xVal);
            FRESetArrayElementAt(cameraQuaternionResult, 0, xVal);
            
            FREObject yVal;
            double y = static_cast<double>(quaternion.y);
            FRENewObjectFromDouble(y, &yVal);
            FRESetArrayElementAt(cameraQuaternionResult, 1, yVal);
            
            FREObject zVal;
            double z = static_cast<double>(quaternion.z);
            FRENewObjectFromDouble(z, &zVal);
            FRESetArrayElementAt(cameraQuaternionResult, 2, zVal);
            
            FREObject wVal;
            double w = static_cast<double>(quaternion.w);
            FRENewObjectFromDouble(w, &wVal);
            FRESetArrayElementAt(cameraQuaternionResult, 3, wVal);
            
            // NSLog(@"Quat Vals: %f,%f,%f,%f", quaternion.x, quaternion.y, quaternion.z, quaternion.w);
            
   //     }
        

        return cameraQuaternionResult;
    }
    
    
    
    FREObject getHMDInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
    {
        FREObject result;
        FRENewObject((const uint8_t*)"Object", 0, NULL, &result, nil);
        
        ovrSizei size = hmd->Resolution;
        /*
        ovrHmd_GetRenderDesc(hmd, <#ovrEyeType eyeType#>, <#ovrFovPort fov#>)
        FREObject hScreenSize;
        FRENewObjectFromDouble(static_cast<double>(size.w), &hScreenSize);
        FRESetObjectProperty(result, (const uint8_t*)"HScreenSize", hScreenSize, NULL);
        
        FREObject vScreenSize;
        FRENewObjectFromDouble(static_cast<double>(size.h), &vScreenSize);
        FRESetObjectProperty(result, (const uint8_t*)"VScreenSize", vScreenSize, NULL);
        
        FREObject eyeToScreenDistance;
        FRENewObjectFromDouble(static_cast<double>(hmd->DefaultEyeFov->), &eyeToScreenDistance);
        FRESetObjectProperty(result, (const uint8_t*)"EyeToScreenDistance", eyeToScreenDistance, NULL);
        
        FREObject lensSeparationDistance;
        FRENewObjectFromDouble(static_cast<double>(info.LensSeparationDistance), &lensSeparationDistance);
        FRESetObjectProperty(result, (const uint8_t*)"LensSeparationDistance", lensSeparationDistance, NULL);
        
        FREObject interPupillaryDistance;
        FRENewObjectFromDouble(static_cast<double>(info.InterpupillaryDistance), &interPupillaryDistance);
        FRESetObjectProperty(result, (const uint8_t*)"InterpupillaryDistance", interPupillaryDistance, NULL);
        
        FREObject kDistortion;
        FRENewObject((const uint8_t*)"Vector.<Number>", 0, NULL, &kDistortion, nil);
        FRESetArrayLength(kDistortion, 4);
        for(int i=0; i<4; i++) {
            FREObject kValue;
            FRENewObjectFromDouble(static_cast<double>(info.DistortionK[i]), &kValue);
            FRESetArrayElementAt(kDistortion, i, kValue);
        }

        FRESetObjectProperty(result, (const uint8_t*)"DistortionK", kDistortion, NULL);
                 */
        return result;
    }
    
    void OculusANE_ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet){
        
        int functions = 3;
        
        *numFunctionsToSet = functions;
        
        FRENamedFunction* func = (FRENamedFunction*)malloc(sizeof(FRENamedFunction)* functions);
        
        func[0].name = (const uint8_t*)"isSupported";
        func[0].functionData = NULL;
        func[0].function = &isSupported;
        
        func[1].name = (const uint8_t*)"getCameraQuaternion";
        func[1].functionData = NULL;
        func[1].function = &getCameraQuaternion;
        
        func[2].name = (const uint8_t*)"getHMDInfo";
        func[2].functionData = NULL;
        func[2].function = &getHMDInfo;
        
        *functionsToSet = func;
        
        NSLog(@"Initialized Native Extension");
        
        ovr_Initialize();
        NSLog(@"Detected %d", ovrHmd_Detect());
        hmd = ovrHmd_Create(0);

        if(hmd==NULL)
        {
            NSLog(@"FATAL: NO HMD");
        }
        bool result = ovrHmd_ConfigureTracking(hmd, ovrTrackingCap_Orientation |
                                 ovrTrackingCap_MagYawCorrection |
                                 ovrTrackingCap_Position, 0);
        NSLog(@"Tracking passed ? %d", result);
    }
    
    void OculusANE_ContextFinalizer(FREContext ctx)
    {
        return;
    }
    
    void OculusANEInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet){
        extDataToSet = NULL;
        *ctxInitializerToSet = &OculusANE_ContextInitializer;
        *ctxFinalizerToSet = &OculusANE_ContextFinalizer;
      
        redirectConsoleLogToDocumentFolder();
    }
    
    void OculusANEFinalizer (FREContext ctx) {
        ovrHmd_Destroy(hmd);
        ovr_Shutdown();
        hmd = NULL;
    }
}