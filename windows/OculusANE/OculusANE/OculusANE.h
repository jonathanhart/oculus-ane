//
//	OculusANE.h
//	Oculus Rift Adobe Native Extension for Windows
//
//	Date: May 28, 2013
//	Author: Micheal MacLean
//	Copyright: (c) 2013 New Nihilist. All rights reserved
//
//	Heavily modified June 5, 2013 to work with jonathanhart/oculus-ane
//

#ifndef OCULUSRIFTANEDLL_H_
#define OCULUSRIFTANEDLL_H_

#include "FlashRuntimeExtensions.h"
#include "..\..\..\oculus_sdk\OculusSDK\LibOVR\Include\OVR.h"


extern "C"
{
	__declspec(dllexport) void initializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);
	__declspec(dllexport) void finalizer(void* extData);
	__declspec(dllexport) FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject getCameraQuaternion(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject getHMDInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	
	//initializer / finalizer
    __declspec(dllexport) void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions);
    __declspec(dllexport) void contextFinalizer(FREContext ctx);

    __declspec(dllexport) void OculusANEInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);
	__declspec(dllexport) void OculusANEFinalizer(void* extData);
}

#endif /* OCULUSRIFTANEDLL_H_ */