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
#include "OVR.h"

extern "C"
{
	__declspec(dllexport) void OculusANEInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);
	__declspec(dllexport) void OculusANEFinalizer(void* extData);
	__declspec(dllexport) FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject getCameraQuaternion(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject getHMDInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject beginFrameTiming(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject endFrameTiming(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject getRenderInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject getCameraPosition(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject getOculusResolution(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject setEnabledCaps(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject getEyePose(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject getEyeTimewarpMatrices(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
}
#endif /* OCULUSRIFTANEDLL_H_ */