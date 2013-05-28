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
#include <string>
#include <sstream>

using namespace std;
using namespace OVR;

extern "C" {
    
    FREObject cameraQuaternionResult;
    FREObject cameraEulerResult;
    
    Ptr<SensorDevice> pSensor;
    SensorFusion fusion;
    Ptr<DeviceManager> pManager;
    
    FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
        FREObject result;
        
        uint32_t isSupportedSwitch = 1;
        FRENewObjectFromBool(isSupportedSwitch, &result);
        
        return result;
    }
    
    FREObject getCameraQuaternion(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
    {
        Quatf quaternion = fusion.GetOrientation();
        
        FRESetArrayElementAt(cameraQuaternionResult, 0, &quaternion.x);
        FRESetArrayElementAt(cameraQuaternionResult, 1, &quaternion.y);
        FRESetArrayElementAt(cameraQuaternionResult, 2, &quaternion.z);
        FRESetArrayElementAt(cameraQuaternionResult, 3, &quaternion.w);

        return cameraQuaternionResult;
    }
    
    void OculusANE_ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet){
        
        int functions = 2;
        
        *numFunctionsToSet = functions;
        
        FRENamedFunction* func = (FRENamedFunction*)malloc(sizeof(FRENamedFunction)* functions);
        
        func[0].name = (const uint8_t*)"isSupported";
        func[0].functionData = NULL;
        func[0].function = &isSupported;
        
        func[1].name = (const uint8_t*)"getCameraQuaternion";
        func[1].functionData = NULL;
        func[1].function = &getCameraQuaternion;
        
        *functionsToSet = func;
        
        OVR::System::Init();
        pManager = *DeviceManager::Create();
        
        DeviceEnumerator<SensorDevice> isensor = pManager->EnumerateDevices<SensorDevice>();
        DeviceEnumerator<SensorDevice> oculusSensor;
        DeviceEnumerator<SensorDevice> oculusSensor2;
        
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
            }
            oculusSensor.Clear();
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
        
        FRENewObject((const uint8_t*)"Vector.<Number>", 0, NULL, &cameraQuaternionResult, nil);
        FRESetArrayLength(&cameraQuaternionResult, 4);
        
        FRENewObject((const uint8_t*)"Vector.<Number>", 0, NULL, &cameraEulerResult, nil);
        FRESetArrayLength(&cameraEulerResult, 3);
    }
    
    void OculusANEFinalizer (FREContext ctx) {
    }
}