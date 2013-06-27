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
#include <string>
#include <sstream>

using namespace std;
using namespace OVR;

extern "C" {
    Ptr<SensorDevice> pSensor;
    SensorFusion fusion;
    Ptr<DeviceManager> pManager;
    Ptr<HMDDevice> pDevice;
    
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
        
        if (pSensor==NULL) {
            isSupportedSwitch = 0;
        }
        
        FRENewObjectFromBool(isSupportedSwitch, &result);
        
        return result;
    }
    
    FREObject getCameraQuaternion(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
    {
        FREObject cameraQuaternionResult;
        FRENewObject((const uint8_t*)"Vector.<Number>", 0, NULL, &cameraQuaternionResult, nil);
        FRESetArrayLength(&cameraQuaternionResult, 4);

        NSLog(@"getCameraQuaternion");
        Quatf quaternion = fusion.GetOrientation();
        
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
        
        return cameraQuaternionResult;
    }
    
    FREObject getHMDInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
    {
        FREObject result;
        FRENewObject((const uint8_t*)"Object", 0, NULL, &result, nil);
        
        HMDInfo info;
        pSensor->GetDeviceInfo(&info);
        
        FREObject hScreenSize;
        FRENewObjectFromDouble(static_cast<double>(info.HScreenSize), &hScreenSize);
        FRESetObjectProperty(result, (const uint8_t*)"HScreenSize", hScreenSize, NULL);

        FREObject vScreenSize;
        FRENewObjectFromDouble(static_cast<double>(info.VScreenSize), &vScreenSize);
        FRESetObjectProperty(result, (const uint8_t*)"VScreenSize", vScreenSize, NULL);

        FREObject vScreenCenter;
        FRENewObjectFromDouble(static_cast<double>(info.VScreenCenter), &vScreenCenter);
        FRESetObjectProperty(result, (const uint8_t*)"VScreenCenter", vScreenCenter, NULL);

        FREObject eyeToScreenDistance;
        FRENewObjectFromDouble(static_cast<double>(info.EyeToScreenDistance), &eyeToScreenDistance);
        FRESetObjectProperty(result, (const uint8_t*)"EyeToScreenDistance", eyeToScreenDistance, NULL);

        FREObject lensSeparationDistance;
        FRENewObjectFromDouble(static_cast<double>(info.LensSeparationDistance), &lensSeparationDistance);
        FRESetObjectProperty(result, (const uint8_t*)"LensSeparationDistance", lensSeparationDistance, NULL);

        FREObject interPupillaryDistance;
        FRENewObjectFromDouble(static_cast<double>(info.InterpupillaryDistance), &interPupillaryDistance);
        FRESetObjectProperty(result, (const uint8_t*)"InterpupillaryDistance", interPupillaryDistance, NULL);
        
        FREObject hResolution;
        FRENewObjectFromDouble(static_cast<double>(info.HResolution), &hResolution);
        FRESetObjectProperty(result, (const uint8_t*)"HResolution", hResolution, NULL);
        
        FREObject vResolution;
        FRENewObjectFromDouble(static_cast<double>(info.VResolution), &vResolution);
        FRESetObjectProperty(result, (const uint8_t*)"VResolution", vResolution, NULL);
        
        FREObject kDistortion;
        FRENewObject((const uint8_t*)"Vector.<Number>", 0, NULL, &kDistortion, nil);
        FRESetArrayLength(kDistortion, 4);
        for(int i=0; i<4; i++) {
            FREObject kValue;
            FRENewObjectFromDouble(static_cast<double>(info.DistortionK[i]), &kValue);
            FRESetArrayElementAt(kDistortion, i, kValue);
        }
        
        FRESetObjectProperty(result, (const uint8_t*)"DistortionK", kDistortion, NULL);
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
        
        OVR::System::Init();
        pManager = *DeviceManager::Create();
        
        NSLog(@"Initialized OVR");
        if (!pManager) {
            NSLog(@"ERROR: pManager null");
        }
        DeviceEnumerator<SensorDevice> isensor = pManager->EnumerateDevices<SensorDevice>();
        DeviceEnumerator<SensorDevice> oculusSensor;
        
        while(isensor)
        {
            DeviceInfo di;
            if (isensor.GetDeviceInfo(&di))
            {
                if (strstr(di.ProductName, "Tracker"))
                {
                    if (!oculusSensor)
                        oculusSensor = isensor;
                    }
            }
            
            isensor.Next();
        }
        
        if (oculusSensor) {
            pSensor = *oculusSensor.CreateDevice();

            // this range is set from the sdk example code
            if (pSensor) {
                pSensor->SetRange(SensorRange(4 * 9.81f, 8 * Math<float>::Pi, 1.0f), true);
                fusion.AttachToSensor(pSensor);
                NSLog(@"Attached to sensor");
            } else {
                NSLog(@"ERROR: pSensor null");
            }
            oculusSensor.Clear();
        } else {
            NSLog(@"ERROR: no Sensor found");
        }
    }
    
    void OculusANE_ContextFinalizer(FREContext ctx)
    {
        if (pManager) {
            pManager.Clear();
        }
        
        if (pSensor) {
            pSensor.Clear();
        }
        
        pManager = NULL;
        pSensor = NULL;
        
        return;
    }
    
    void OculusANEInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet){
        extDataToSet = NULL;
        *ctxInitializerToSet = &OculusANE_ContextInitializer;
        *ctxFinalizerToSet = &OculusANE_ContextFinalizer;
      
        //redirectConsoleLogToDocumentFolder();
    }
    
    void OculusANEFinalizer (FREContext ctx) {
    }
}