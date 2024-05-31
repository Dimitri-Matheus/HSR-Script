/** Motion Blur effect PS, version 1.0.6

This code © 2022 Jakub Maksymilian Fober

This work is licensed under the Creative Commons
Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit
http://creativecommons.org/licenses/by-nc-nd/3.0/.

Copyright owner further grants permission for commercial reuse of
image recordings derived from the Work (e.g. let's play video,
gameplay stream with ReShade filters, screenshots with ReShade
filters) provided that any use is accompanied by the name of the
shader used and a link to ReShade website https://reshade.me.

If you need additional licensing for your commercial product, contact
me at jakub.m.fober@protonmail.com.

For updates visit GitHub repository at
https://github.com/Fubaxiusz/fubax-shaders.
*/

	/* MACROS */

#include "ReShade.fxh"
#include "ReShadeUI.fxh"
#include "ColorAndDither.fxh"

	/* UNIFORMS */

uniform uint framecount < source = "framecount"; >;

	/* TEXTURES */

// Previous frame render target buffer
texture InterlacedTargetBuffer
{
	Width = BUFFER_WIDTH;
	Height = BUFFER_HEIGHT;
};
sampler InterlacedBufferSampler
{
	Texture = InterlacedTargetBuffer;
	MagFilter = POINT;
	MinFilter = POINT;
	MipFilter = POINT;
	// Linear workflow
	SRGBTexture = true;
};

	/* SHADERS */

// Generate a triangle covering the entire screen
float4 InterlacedVS(in uint id : SV_VertexID) : SV_Position
{
	// Define vertex position
	const float2 vertexPos[3] = {
		float2(-1f, 1f), // Top left
		float2(-1f,-3f), // Bottom left
		float2( 3f, 1f)  // Top right
	};
	return float4(vertexPos[id], 0f, 1f);
}

// Preserve previous frame
void InterlacedTargetPass(float4 pixelPos : SV_Position, out float4 Target : SV_Target)
{
	// Get pixel coordinates
	uint2 pixelCoord = uint2(pixelPos.xy);
	// Get present frame
	Target.rgb = tex2Dfetch(ReShade::BackBuffer, pixelCoord).rgb;
	// Get noise channel offset for variability
	uint offset = uint(4f*tex2Dfetch(BlueNoise::BlueNoiseTexSmp, pixelCoord/DITHER_SIZE_TEX%DITHER_SIZE_TEX).r);
	offset += framecount;
	// Get blue noise alpha mask
	Target.a = tex2Dfetch(BlueNoise::BlueNoiseTexSmp, pixelCoord%DITHER_SIZE_TEX)[offset%4u];
}

// Combine previous and current frame
float4 InterlacedPS(float4 pixelPos : SV_Position) : SV_Target
{ return tex2Dfetch(InterlacedBufferSampler, uint2(pixelPos.xy)); }


	/* OUTPUT */

technique BlueNoiseMotion
<
	ui_label = "Blue Noise Motion Blur";
	ui_tooltip =
		"It generates 'fake' motion blur, by blending previous frames.\n"
		"The smoothness is achieved by incorporating blue noise as a blending pattern.\n"
		"\n"
		"To get higher quality results, the game should be running at higher FPS.\n"
		"\n"
		"This effect © 2022 Jakub Maksymilian Fober\n"
		"Licensed under CC BY-NC-ND 3.0 + additional permissions (see source).";
>{
	pass GatherFrames
	{
		VertexShader = InterlacedVS;
		PixelShader = InterlacedTargetPass;

		RenderTarget = InterlacedTargetBuffer;

		ClearRenderTargets = false;
		SRGBWriteEnable = true; // Linear workflow

		BlendEnable = true;
			BlendOp = ADD; // Mimic linear interpolation
				SrcBlend = SRCALPHA;
				DestBlend = INVSRCALPHA;
	}
	pass DisplayEffect
	{
		VertexShader = InterlacedVS;
		PixelShader = InterlacedPS;
	}
}
