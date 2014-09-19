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

	ovrHmd HMD = NULL;
	ovrEyeRenderDesc	eyeRenderDesc[2];
	ovrRecti			eyeRenderViewport[2];
	ovrVector2f			UVScaleOffset[2][2];
	Sizei				renderTargetSize;
	ovrFovPort			eyeFov[2];
	static ovrPosef eyeRenderPose[2];
	
	FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		FREObject result;

		uint32_t isSupportedSwitch = 1;

		if (HMD == NULL) {
			isSupportedSwitch = 0;
		}

		FRENewObjectFromBool(isSupportedSwitch, &result);

		return result;
	}

	FREObject getResolution(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		FREObject resolutionResult;
		FRENewObject((const uint8_t*)"Vector.<Number>", 0, NULL, &resolutionResult, NULL);
		FRESetArrayLength(&resolutionResult, 2);

		ovrSizei size = HMD->Resolution;

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




	FREObject getCameraPosition(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		FREObject positionResult;
		FRENewObject((const uint8_t*)"Vector.<Number>", 0, NULL, &positionResult, NULL);
		FRESetArrayLength(&positionResult, 6);

		for (int eyeIndex = 0; eyeIndex < ovrEye_Count; eyeIndex++)
		{
			ovrEyeType eye = HMD->EyeRenderOrder[eyeIndex];
			eyeRenderPose[eye] = ovrHmd_GetEyePose(HMD, eye);

			FREObject xVal;
			double x = static_cast<double>(eyeRenderPose[eye].Position.x);
			FRENewObjectFromDouble(x, &xVal);
			FRESetArrayElementAt(positionResult, (eyeIndex * 3) + 0, xVal);

			FREObject yVal;
			double y = static_cast<double>(eyeRenderPose[eye].Position.y);
			FRENewObjectFromDouble(y, &yVal);
			FRESetArrayElementAt(positionResult, (eyeIndex * 3) + 1, yVal);

			FREObject zVal;
			double z = static_cast<double>(eyeRenderPose[eye].Position.z);
			FRENewObjectFromDouble(z, &zVal);
			FRESetArrayElementAt(positionResult, (eyeIndex * 3) + 2, zVal);
		}


		return positionResult;
	}

	FREObject getCameraQuaternion(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		FREObject cameraQuaternionResult;
		FRENewObject((const uint8_t*)"Vector.<Number>", 0, NULL, &cameraQuaternionResult, NULL);
		FRESetArrayLength(&cameraQuaternionResult, 4);

		// Query the HMD for the current tracking state.
		ovrTrackingState ts = ovrHmd_GetTrackingState(HMD, ovr_GetTimeInSeconds());
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

		return cameraQuaternionResult;
	}


	FREObject getRenderInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		FREObject result;
		FRENewObject((const uint8_t*)"Object", 0, NULL, &result, NULL);


		FREObject freEyeInfos;
		FRENewObject((const uint8_t*)"Vector.<Object>", 0, NULL, &freEyeInfos, NULL);
		FRESetArrayLength(freEyeInfos, 2);


		ovrHmd_BeginFrameTiming(HMD, 0);
		// Retrieve data useful for handling the Health and Safety Warning - unused, but here for reference
		ovrHSWDisplayState hswDisplayState;
		ovrHmd_GetHSWDisplayState(HMD, &hswDisplayState);

		// Adjust eye position and rotation from controls, maintaining y position from HMD.
		static float    BodyYaw(3.141592f);
		static Vector3f HeadPos(0.0f, 1.6f, -5.0f);
		HeadPos.y = ovrHmd_GetFloat(HMD, OVR_KEY_EYE_HEIGHT, HeadPos.y);
		
		for (int eyeNum = 0; eyeNum < ovrEye_Count; eyeNum++)
		{
			ovrEyeType eye = HMD->EyeRenderOrder[eyeNum];
			eyeRenderPose[eye] = ovrHmd_GetEyePose(HMD, eye);

			// Get view and projection matrices
			Matrix4f rollPitchYaw = Matrix4f::RotationY(BodyYaw);
			Matrix4f finalRollPitchYaw = rollPitchYaw * Matrix4f(eyeRenderPose[eye].Orientation);
			Vector3f finalUp = finalRollPitchYaw.Transform(Vector3f(0, 1, 0));
			Vector3f finalForward = finalRollPitchYaw.Transform(Vector3f(0, 0, -1));
			Vector3f shiftedEyePos = HeadPos + rollPitchYaw.Transform(eyeRenderPose[eye].Position);
			Matrix4f view = Matrix4f::LookAtRH(shiftedEyePos, shiftedEyePos + finalForward, finalUp);
			Matrix4f proj = ovrMatrix4f_Projection(eyeRenderDesc[eye].Fov, 0.01f, 10000.0f, true);

			//pRender->SetViewport(Recti(EyeRenderViewport[eye]));
			//pRender->SetProjection(proj);
			//pRender->SetDepthMode(true, true);
			//pRoomScene->Render(pRender, Matrix4f::Translation(eyeRenderDesc[eye].ViewAdjust) * view);

			FREObject freEyeInfo;
			FRENewObject((const uint8_t*)"Object", 0, NULL, &freEyeInfo, NULL);


			FREObject freProjection;
			FRENewObject((const uint8_t*)"Vector.<Number>", 0, NULL, &freProjection, NULL);
			FRESetArrayLength(freProjection, 16);
			for (int i = 0; i<4; i++) {
				for (int j = 0; j<4; j++) {
					FREObject raw;
					FRENewObjectFromDouble(static_cast<double>(proj.M[i][j]), &raw);
					FRESetArrayElementAt(freProjection, (4 * i) + j, raw);
				}
			}

			FRESetObjectProperty(freEyeInfo, (const uint8_t*)"projection", freProjection, NULL);
			


			// Get and set shader constants
			//Shaders->SetUniform2f("EyeToSourceUVScale", UVScaleOffset[eyeNum][0].x, UVScaleOffset[eyeNum][0].y);
			//Shaders->SetUniform2f("EyeToSourceUVOffset", UVScaleOffset[eyeNum][1].x, UVScaleOffset[eyeNum][1].y);

			/*
			ovrHmd_GetRenderScaleAndOffset(eyeFov[eyeNum], renderTargetSize, eyeRenderViewport[eyeNum], UVScaleOffset[eyeNum]);

			// PUSHING UVScaleOffset SIZE INFO
			FREObject freUVScaleOffset;
			FRENewObject((const uint8_t*)"Object", 0, NULL, &freUVScaleOffset, NULL);

			FREObject freEyeToSourceUVScale;
			FRENewObject((const uint8_t*)"Object", 0, NULL, &freEyeToSourceUVScale, NULL);

			FREObject freEyeToSourceUVScaleX;
			FRENewObjectFromDouble(static_cast<double>(UVScaleOffset[eyeNum][0].x), &freEyeToSourceUVScaleX);
			FRESetObjectProperty(freEyeToSourceUVScale, (const uint8_t*)"x", freEyeToSourceUVScaleX, NULL);

			FREObject freEyeToSourceUVScaleY;
			FRENewObjectFromDouble(static_cast<double>(UVScaleOffset[eyeNum][0].y), &freEyeToSourceUVScaleY);
			FRESetObjectProperty(freEyeToSourceUVScale, (const uint8_t*)"y", freEyeToSourceUVScaleY, NULL);

			FRESetObjectProperty(freUVScaleOffset, (const uint8_t*)"eyeToSourceUVScale", freEyeToSourceUVScale, NULL);


			FREObject freEyeToSourceUVOffset;
			FRENewObject((const uint8_t*)"Object", 0, NULL, &freEyeToSourceUVOffset, NULL);

			FREObject freEyeToSourceUVOffsetX;
			FRENewObjectFromDouble(static_cast<double>(UVScaleOffset[eyeNum][1].x), &freEyeToSourceUVOffsetX);
			FRESetObjectProperty(freEyeToSourceUVOffset, (const uint8_t*)"x", freEyeToSourceUVOffsetX, NULL);

			FREObject freEyeToSourceUVOffsetY;
			FRENewObjectFromDouble(static_cast<double>(UVScaleOffset[eyeNum][1].y), &freEyeToSourceUVOffsetY);
			FRESetObjectProperty(freEyeToSourceUVOffset, (const uint8_t*)"y", freEyeToSourceUVOffsetY, NULL);

			FRESetObjectProperty(freUVScaleOffset, (const uint8_t*)"eyeToSourceUVOffset", freEyeToSourceUVOffset, NULL);

			FRESetObjectProperty(freEyeInfo, (const uint8_t*)"UVScaleOffset", freUVScaleOffset, NULL);
			*/



			ovrMatrix4f timeWarpMatrices[2];
			ovrHmd_GetEyeTimewarpMatrices(HMD, (ovrEyeType)eyeNum, eyeRenderPose[eyeNum], timeWarpMatrices);
			//Shaders->SetUniform4x4f("EyeRotationStart", timeWarpMatrices[0]);  //Nb transposed when set
			//Shaders->SetUniform4x4f("EyeRotationEnd", timeWarpMatrices[1]);  //Nb transposed when set
			// Perform distortion
			//pRender->Render(&distortionShaderFill, MeshVBs[eyeNum], MeshIBs[eyeNum], sizeof(ovrDistortionVertex));

			FRESetArrayElementAt(freEyeInfos, eyeNum, freEyeInfo);
			FRESetObjectProperty(result, (const uint8_t*)"eyeInfos", freEyeInfos, NULL);
		}

		


		ovrHmd_EndFrameTiming(HMD);

		return result;
	}

	


	FREObject getHMDInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		FREObject result;
		FRENewObject((const uint8_t*)"Object", 0, NULL, &result, NULL);

		
		#ifndef max
		#define max(a,b)            (((a) > (b)) ? (a) : (b))
		#endif

		//Configure Stereo settings.
		Sizei recommenedTex0Size = ovrHmd_GetFovTextureSize(HMD, ovrEye_Left, HMD->DefaultEyeFov[0], 1.0f);
		Sizei recommenedTex1Size = ovrHmd_GetFovTextureSize(HMD, ovrEye_Right, HMD->DefaultEyeFov[1], 1.0f);

		renderTargetSize.w = recommenedTex0Size.w + recommenedTex1Size.w;
		renderTargetSize.h = max(recommenedTex0Size.h, recommenedTex1Size.h);

		// Initialize eye rendering information.
		// The viewport sizes are re-computed in case RenderTargetSize changed due to HW limitations.
		ovrFovPort eyeFov[2] = { HMD->DefaultEyeFov[0], HMD->DefaultEyeFov[1] };

		eyeRenderViewport[0].Pos = Vector2i(0, 0);
		eyeRenderViewport[0].Size = Sizei(renderTargetSize.w / 2, renderTargetSize.h);
		eyeRenderViewport[1].Pos = Vector2i((renderTargetSize.w + 1) / 2, 0);
		eyeRenderViewport[1].Size = eyeRenderViewport[0].Size;

		// PUSHING RENDERTARGET SIZE INFO
		FREObject freRenderTargetSize;
		FRENewObject((const uint8_t*)"Object", 0, NULL, &freRenderTargetSize, NULL);

		FREObject freRenderTargetSizeW;
		FRENewObjectFromDouble(static_cast<double>(renderTargetSize.w), &freRenderTargetSizeW);
		FRESetObjectProperty(freRenderTargetSize, (const uint8_t*)"w", freRenderTargetSizeW, NULL);

		FREObject freRenderTargetSizeH;
		FRENewObjectFromDouble(static_cast<double>(renderTargetSize.h), &freRenderTargetSizeH);
		FRESetObjectProperty(freRenderTargetSize, (const uint8_t*)"h", freRenderTargetSizeH, NULL);


		FRESetObjectProperty(result, (const uint8_t*)"renderTargetSize", freRenderTargetSize, NULL);


		float eyeHeight = ovrHmd_GetFloat(HMD, OVR_KEY_EYE_HEIGHT, OVR_DEFAULT_EYE_HEIGHT);
		FREObject freEyeHeight;
		FRENewObjectFromDouble(static_cast<double>(eyeHeight), &freEyeHeight);
		FRESetObjectProperty(result, (const uint8_t*)"eyeHeight", freEyeHeight, NULL);
		
		float playerHeight = ovrHmd_GetFloat(HMD, OVR_KEY_PLAYER_HEIGHT, OVR_DEFAULT_PLAYER_HEIGHT);
		FREObject frePlayerHeight;
		FRENewObjectFromDouble(static_cast<double>(playerHeight), &frePlayerHeight);
		FRESetObjectProperty(result, (const uint8_t*)"playerHeight", frePlayerHeight, NULL);

		float IPD = ovrHmd_GetFloat(HMD, OVR_KEY_IPD, OVR_DEFAULT_IPD);
		FREObject freIPD;
		FRENewObjectFromDouble(static_cast<double>(IPD), &freIPD);
		FRESetObjectProperty(result, (const uint8_t*)"IPD", freIPD, NULL);

		float neckToEyeDistance = ovrHmd_GetFloat(HMD, OVR_KEY_NECK_TO_EYE_DISTANCE, OVR_DEFAULT_NECK_TO_EYE_VERTICAL);
		FREObject freNeckToEyeDistance;
		FRENewObjectFromDouble(static_cast<double>(neckToEyeDistance), &freNeckToEyeDistance);
		FRESetObjectProperty(result, (const uint8_t*)"neckToEyeDistance", freNeckToEyeDistance, NULL);



		FREObject freEyeInfos;
		FRENewObject((const uint8_t*)"Vector.<Object>", 0, NULL, &freEyeInfos, NULL);
		FRESetArrayLength(freEyeInfos, 2);

		//Generate distortion mesh for each eye
		for (int eyeNum = 0; eyeNum < 2; eyeNum++)
		{
			if (eyeNum == 0){
				eyeRenderDesc[eyeNum] = ovrHmd_GetRenderDesc(HMD, ovrEye_Left, eyeFov[eyeNum]);
			}
			else{
				eyeRenderDesc[eyeNum] = ovrHmd_GetRenderDesc(HMD, ovrEye_Right, eyeFov[eyeNum]);
			}
			


			ovrDistortionMesh meshData;
			
			// Allocate  &  generate  distortion  mesh  vertices. ovrDistortionMesh meshData; 
			ovrHmd_CreateDistortionMesh(HMD, eyeRenderDesc[eyeNum].Eye, eyeRenderDesc[eyeNum].Fov, ovrDistortionCap_Chromatic | ovrDistortionCap_TimeWarp, &meshData);


			FREObject freEyeInfo;
			FRENewObject((const uint8_t*)"Object", 0, NULL, &freEyeInfo, NULL);


			ovrMatrix4f proj = ovrMatrix4f_Projection(eyeRenderDesc[eyeNum].Fov, 0.01f, 10000.0f, true);

			FREObject freProjection;
			FRENewObject((const uint8_t*)"Vector.<Number>", 0, NULL, &freProjection, NULL);
			FRESetArrayLength(freProjection, 16);
			for (int i = 0; i<4; i++) {
				for (int j = 0; j<4; j++) {
					FREObject kValue;
					FRENewObjectFromDouble(static_cast<double>(proj.M[i][j]), &kValue);
					FRESetArrayElementAt(freProjection, (4*i)+j, kValue);
				}
			}

			FRESetObjectProperty(freEyeInfo, (const uint8_t*)"projection", freProjection, NULL);


			//Do scale and offset
			ovrHmd_GetRenderScaleAndOffset(eyeFov[eyeNum], renderTargetSize, eyeRenderViewport[eyeNum], UVScaleOffset[eyeNum]);


			// PUSHING UVScaleOffset SIZE INFO
			FREObject freUVScaleOffset;
			FRENewObject((const uint8_t*)"Object", 0, NULL, &freUVScaleOffset, NULL);

				FREObject freEyeToSourceUVScale;
				FRENewObject((const uint8_t*)"Object", 0, NULL, &freEyeToSourceUVScale, NULL);

					FREObject freEyeToSourceUVScaleX;
					FRENewObjectFromDouble(static_cast<double>(UVScaleOffset[eyeNum][0].x), &freEyeToSourceUVScaleX);
					FRESetObjectProperty(freEyeToSourceUVScale, (const uint8_t*)"x", freEyeToSourceUVScaleX, NULL);

					FREObject freEyeToSourceUVScaleY;
					FRENewObjectFromDouble(static_cast<double>(UVScaleOffset[eyeNum][0].y), &freEyeToSourceUVScaleY);
					FRESetObjectProperty(freEyeToSourceUVScale, (const uint8_t*)"y", freEyeToSourceUVScaleY, NULL);

				FRESetObjectProperty(freUVScaleOffset, (const uint8_t*)"eyeToSourceUVScale", freEyeToSourceUVScale, NULL);


				FREObject freEyeToSourceUVOffset;
				FRENewObject((const uint8_t*)"Object", 0, NULL, &freEyeToSourceUVOffset, NULL);

					FREObject freEyeToSourceUVOffsetX;
					FRENewObjectFromDouble(static_cast<double>(UVScaleOffset[eyeNum][1].x), &freEyeToSourceUVOffsetX);
					FRESetObjectProperty(freEyeToSourceUVOffset, (const uint8_t*)"x", freEyeToSourceUVOffsetX, NULL);

					FREObject freEyeToSourceUVOffsetY;
					FRENewObjectFromDouble(static_cast<double>(UVScaleOffset[eyeNum][1].y), &freEyeToSourceUVOffsetY);
					FRESetObjectProperty(freEyeToSourceUVOffset, (const uint8_t*)"y", freEyeToSourceUVOffsetY, NULL);

				FRESetObjectProperty(freUVScaleOffset, (const uint8_t*)"eyeToSourceUVOffset", freEyeToSourceUVOffset, NULL);

			FRESetObjectProperty(freEyeInfo, (const uint8_t*)"UVScaleOffset", freUVScaleOffset, NULL);




			FREObject freEyeInfoIndexCount;
			FRENewObjectFromDouble(static_cast<double>(meshData.IndexCount), &freEyeInfoIndexCount);
			FRESetObjectProperty(freEyeInfo, (const uint8_t*)"indexCount", freEyeInfoIndexCount, NULL);

			FREObject freEyeInfoVertexCount;
			FRENewObjectFromDouble(static_cast<double>(meshData.VertexCount), &freEyeInfoVertexCount);
			FRESetObjectProperty(freEyeInfo, (const uint8_t*)"vertexCount", freEyeInfoVertexCount, NULL);

			FREObject freEyeInfoVertexData;
			FRENewObject((const uint8_t*)"Vector.<Object>", 0, NULL, &freEyeInfoVertexData, NULL);
			FRESetArrayLength(freEyeInfoVertexData, meshData.VertexCount);


			// Now parse the vertex data and create a render ready vertex buffer from it
			ovrDistortionVertex * ov = meshData.pVertexData;
			for (unsigned vertNum = 0; vertNum < meshData.VertexCount; vertNum++)
			{
				FREObject freEyeInfoVertexObj;
				FRENewObject((const uint8_t*)"Object", 0, NULL, &freEyeInfoVertexObj, NULL);

				FREObject freScreenPosX;
				FRENewObjectFromDouble(static_cast<double>(ov->ScreenPosNDC.x), &freScreenPosX);
				FRESetObjectProperty(freEyeInfoVertexObj, (const uint8_t*)"posX", freScreenPosX, NULL);

				FREObject freScreenPosY;
				FRENewObjectFromDouble(static_cast<double>(ov->ScreenPosNDC.y), &freScreenPosY);
				FRESetObjectProperty(freEyeInfoVertexObj, (const uint8_t*)"posY", freScreenPosY, NULL);


				// TEXR
				FREObject freTanEyeAnglesR;
				FRENewObject((const uint8_t*)"Object", 0, NULL, &freTanEyeAnglesR, NULL);

				FREObject freTanEyeAnglesRX;
				FRENewObjectFromDouble(static_cast<double>((*(Vector2f*)&ov->TanEyeAnglesR).x), &freTanEyeAnglesRX);
				FRESetObjectProperty(freTanEyeAnglesR, (const uint8_t*)"x", freTanEyeAnglesRX, NULL);

				FREObject freTanEyeAnglesRY;
				FRENewObjectFromDouble(static_cast<double>((*(Vector2f*)&ov->TanEyeAnglesR).y), &freTanEyeAnglesRY);
				FRESetObjectProperty(freTanEyeAnglesR, (const uint8_t*)"y", freTanEyeAnglesRY, NULL);

				FRESetObjectProperty(freEyeInfoVertexObj, (const uint8_t*)"texR", freTanEyeAnglesR, NULL);
				

				// TEXG
				FREObject freTanEyeAnglesG;
				FRENewObject((const uint8_t*)"Object", 0, NULL, &freTanEyeAnglesG, NULL);

				FREObject freTanEyeAnglesGX;
				FRENewObjectFromDouble(static_cast<double>((*(Vector2f*)&ov->TanEyeAnglesG).x), &freTanEyeAnglesGX);
				FRESetObjectProperty(freTanEyeAnglesG, (const uint8_t*)"x", freTanEyeAnglesGX, NULL);

				FREObject freTanEyeAnglesGY;
				FRENewObjectFromDouble(static_cast<double>((*(Vector2f*)&ov->TanEyeAnglesG).y), &freTanEyeAnglesGY);
				FRESetObjectProperty(freTanEyeAnglesG, (const uint8_t*)"y", freTanEyeAnglesGY, NULL);

				FRESetObjectProperty(freEyeInfoVertexObj, (const uint8_t*)"texG", freTanEyeAnglesG, NULL);


				// TEXB
				FREObject freTanEyeAnglesB;
				FRENewObject((const uint8_t*)"Object", 0, NULL, &freTanEyeAnglesB, NULL);

				FREObject freTanEyeAnglesBX;
				FRENewObjectFromDouble(static_cast<double>((*(Vector2f*)&ov->TanEyeAnglesB).x), &freTanEyeAnglesBX);
				FRESetObjectProperty(freTanEyeAnglesB, (const uint8_t*)"x", freTanEyeAnglesBX, NULL);

				FREObject freTanEyeAnglesBY;
				FRENewObjectFromDouble(static_cast<double>((*(Vector2f*)&ov->TanEyeAnglesB).y), &freTanEyeAnglesBY);
				FRESetObjectProperty(freTanEyeAnglesB, (const uint8_t*)"y", freTanEyeAnglesBY, NULL);

				FRESetObjectProperty(freEyeInfoVertexObj, (const uint8_t*)"texB", freTanEyeAnglesB, NULL);



				FREObject freColRGB;
				FRENewObjectFromDouble(static_cast<double>((OVR::UByte)(ov->VignetteFactor * 255.99f)), &freColRGB);
				FRESetObjectProperty(freEyeInfoVertexObj, (const uint8_t*)"colRGB", freColRGB, NULL);


				FREObject freColA; // lol free cola
				FRENewObjectFromDouble(static_cast<double>((OVR::UByte)(ov->TimeWarpFactor * 255.99f)), &freColA);
				FRESetObjectProperty(freEyeInfoVertexObj, (const uint8_t*)"colA", freColA, NULL);
				
				//v->Pos.x = ov->ScreenPosNDC.x;
				//v->Pos.y = ov->ScreenPosNDC.y;
				//v->TexR = (*(Vector2f*)&ov->TanEyeAnglesR); 
				//v->TexG = (*(Vector2f*)&ov->TanEyeAnglesG); 
				//v->TexB = (*(Vector2f*)&ov->TanEyeAnglesB);
				//v->Col.R = v->Col.G = v->Col.B = (OVR::UByte)(ov->VignetteFactor * 255.99f);
				//v->Col.A = (OVR::UByte)(ov->TimeWarpFactor * 255.99f);
	
				ov++;
				FRESetArrayElementAt(freEyeInfoVertexData, vertNum, freEyeInfoVertexObj);
			}
			
			FRESetObjectProperty(freEyeInfo, (const uint8_t*)"vertexData", freEyeInfoVertexData, NULL);
			FRESetArrayElementAt(freEyeInfos, eyeNum, freEyeInfo);


			FREObject freIndexData;
			FRENewObject((const uint8_t*)"Vector.<Number>", 0, NULL, &freIndexData, NULL);
			FRESetArrayLength(freIndexData, meshData.IndexCount);

			
			int i;
			for (unsigned int indexNum = 0; indexNum < meshData.IndexCount; indexNum++)
			{
				i = meshData.pIndexData[indexNum];

				FREObject freIndex;
				FRENewObjectFromUint32(i, &freIndex);
				FRESetArrayElementAt(freIndexData, indexNum, freIndex);
			}

			FRESetObjectProperty(freEyeInfo, (const uint8_t*)"indexData", freIndexData, NULL);

			ovrHmd_DestroyDistortionMesh(&meshData);
		}


		FRESetObjectProperty(result, (const uint8_t*)"eyeInfos", freEyeInfos, NULL);

		return result;
	}

	void OculusANE_ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet){

		int functions = 6;

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

		func[3].name = (const uint8_t*)"getRenderInfo";
		func[3].functionData = NULL;
		func[3].function = &getRenderInfo;

		func[4].name = (const uint8_t*)"getOculusResolution";
		func[4].functionData = NULL;
		func[4].function = &getResolution;

		func[5].name = (const uint8_t*)"getCameraPosition";
		func[5].functionData = NULL;
		func[5].function = &getCameraPosition;
		*functionsToSet = func;

		cout << "Initialized Native Extension\n";

		ovr_Initialize();
		HMD = ovrHmd_Create(0);
		if (!HMD)
		{
			cout << "Oculus Rift not detected.\n";
			//return;
		}
		else{
			if (HMD->ProductName[0] == '\0'){
				cout << "Rift detected, display not enabled.\n";
			}
			else{
				cout << "Rift detected.";
				cout << HMD->Handle;
				ovrHmd_SetEnabledCaps(HMD, ovrHmdCap_DynamicPrediction);

				// Start the sensor which informs of the Rift's pose and motion
				bool result = ovrHmd_ConfigureTracking(HMD, ovrTrackingCap_Orientation |
					ovrTrackingCap_MagYawCorrection |
					ovrTrackingCap_Position, 0);

			}
		}
	}

	void OculusANE_ContextFinalizer(FREContext ctx)
	{
		return;
	}

	void OculusANEInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet){
		extDataToSet = NULL;
		*ctxInitializerToSet = &OculusANE_ContextInitializer;
		*ctxFinalizerToSet = &OculusANE_ContextFinalizer;

		//redirectConsoleLogToDocumentFolder();
	}

	void OculusANEFinalizer(FREContext ctx) {
		if (HMD){
			ovrHmd_Destroy(HMD);
		}

		ovr_Shutdown();
		HMD = NULL;
	}
}