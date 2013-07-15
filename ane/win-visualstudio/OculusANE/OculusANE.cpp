//
//	OculusANE.cpp
//	Oculus Rift Adobe Native Extension for Windows
//
//	Date: May 28, 2013
//	Author: Micheal MacLean
//	Copyright: (c) 2013 New Nihilist. All rights reserved
//
//	Heavily modified June 5, 2013 to work with jonathanhart/oculus-ane
//

#include "OculusANE.h"

#include <stdlib.h>
#include <iostream>
#include <conio.h>

using namespace OVR;
using namespace std;

extern "C" {

	Ptr<SensorDevice> pSensor;
	SensorFusion fusion;
	Ptr<DeviceManager> pManager;
	Ptr<HMDDevice> pHMD;
	
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
		FRENewObject((const uint8_t*)"Vector.<Number>", 0, NULL, &cameraQuaternionResult, NULL);
		FRESetArrayLength(&cameraQuaternionResult, 4);
		
		// cout << "getCameraQuaternion";
		//Quatf quaternion = fusion.GetOrientation();
		Quatf quaternion = fusion.GetPredictedOrientation();
		
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
		 
		return cameraQuaternionResult;
	}
	
	FREObject getHMDInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		FREObject result;
		FRENewObject((const uint8_t*)"Object", 0, NULL, &result, NULL);
        
		HMDInfo info;
		pHMD->GetDeviceInfo(&info);
	        
		FREObject hScreenSize;
		FRENewObjectFromDouble(static_cast<double>(info.HScreenSize), &hScreenSize);
		FRESetObjectProperty(result, (const uint8_t*)"hScreenSize", hScreenSize, NULL);

		FREObject vScreenSize;
		FRENewObjectFromDouble(static_cast<double>(info.VScreenSize), &vScreenSize);
		FRESetObjectProperty(result, (const uint8_t*) "vScreenSize", vScreenSize, NULL);

		FREObject vScreenCenter;
		FRENewObjectFromDouble(static_cast<double>(info.VScreenCenter), &vScreenCenter);
		FRESetObjectProperty(result, (const uint8_t*) "vScreenCenter", vScreenCenter, NULL);

		FREObject eyeToScreenDistance;
		FRENewObjectFromDouble(static_cast<double>(info.EyeToScreenDistance), &eyeToScreenDistance);
		FRESetObjectProperty(result, (const uint8_t*) "eyeToScreenDistance", eyeToScreenDistance, NULL);

		FREObject lensSeparationDistance;
		FRENewObjectFromDouble(static_cast<double>(info.LensSeparationDistance), &lensSeparationDistance);
		FRESetObjectProperty(result, (const uint8_t*) "lensSeparationDistance", lensSeparationDistance, NULL);

		FREObject interPupillaryDistance;
		FRENewObjectFromDouble(static_cast<double>(info.InterpupillaryDistance), &interPupillaryDistance);
		FRESetObjectProperty(result, (const uint8_t*) "interPupillaryDistance", interPupillaryDistance, NULL);
        
		FREObject hResolution;
		FRENewObjectFromDouble(static_cast<double>(info.HResolution), &hResolution);
		FRESetObjectProperty(result, (const uint8_t*) "hResolution", hResolution, NULL);
        
		FREObject vResolution;
		FRENewObjectFromDouble(static_cast<double>(info.VResolution), &vResolution);
		FRESetObjectProperty(result, (const uint8_t*) "vResolution", vResolution, NULL);
        
		FREObject distortionK;
		FRENewObject((const uint8_t*) "Vector.<Number>", 0, NULL, &distortionK, NULL);
		FRESetArrayLength(distortionK, 4);
		for(int i=0; i<4; i++) {
			FREObject kValue;
			FRENewObjectFromDouble(static_cast<double>(info.DistortionK[i]), &kValue);
			FRESetArrayElementAt(distortionK, i, kValue);
		}
		FRESetObjectProperty(result, (const uint8_t*) "distortionK", distortionK, NULL);


		FREObject chromaAbCorrection;
		FRENewObject((const uint8_t*) "Vector.<Number>", 0, NULL, &chromaAbCorrection, NULL);
		FRESetArrayLength(chromaAbCorrection, 4);
		for (int i = 0; i < 4; i++) {
			FREObject cValue;
			FRENewObjectFromDouble(static_cast<double>(info.ChromaAbCorrection[i]), &cValue);
			FRESetArrayElementAt(chromaAbCorrection, i, cValue);
		}
		FRESetObjectProperty(result, (const uint8_t*) "chromaAbCorrection", chromaAbCorrection, NULL);
        

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
        
		cout << "Initialized Native Extension\n";
        
		OVR::System::Init();
		pManager = *DeviceManager::Create();
		pHMD = *pManager->EnumerateDevices<HMDDevice>().CreateDevice();
        
		cout << "Initialized OVR\n";
		if (!pManager) {
			cout << "ERROR: pManager null\n";
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
				fusion.SetPredictionEnabled(true);
				cout << "Attached to sensor\n";
			} else {
				cout << "ERROR: pSensor null\n";
			}
			oculusSensor.Clear();
		} else {
			cout << "ERROR: no Sensor found\n";
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
	}
    
	void OculusANEFinalizer (FREContext ctx) {
	}
}