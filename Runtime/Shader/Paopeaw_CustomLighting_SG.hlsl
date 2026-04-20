#ifndef SG_PAOPEAW_LIGHTING_SG_INCLUDED
#define SG_PAOPEAW_LIGHTING_SG_INCLUDED

#ifndef SHADERGRAPH_PREVIEW
    #if SHADERPASS != SHADERPASS_FORWARD && SHADERPASS != SHADERPASS_GBUFFER
        // #if to avoid "duplicate keyword" warnings if this is included in a Lit Graph

        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _CLUSTER_LIGHT_LOOP

        // Left some keywords (e.g. light layers, cookies) in subgraphs to help avoid unnecessary shader variants
        // But means if those subgraphs are nested in another, you'll need to copy the keywords from blackboard

    #endif
#endif

#include "Paopeaw_CustomLighting_Core.hlsl"

void SampleSSAO_float(float4 ScreenPosition, out float Occlusion)
{
    #ifdef SHADERGRAPH_PREVIEW
        Occlusion = 1.0;
    #else
        float2 uv = ScreenPosition.xy / ScreenPosition.w;
        Occlusion = 1.0;
    #endif
}

void StylizedMainLight_float(
    float3 PositionWS,
    float3 NormalWS,
    float3 ViewDirWS,
    float3 Albedo,
    float  Metallic,
    float  Smoothness,
    float  ShadowThreshold,
    float  ShadowSmoothness,
    float3 ShadowColor,
    float  SpecularStrength,
    float3 SpecularColor,
    float  SpecularThreshold,
    float  SpecularSmoothness,
    out float3 Color)
{
    #ifdef SHADERGRAPH_PREVIEW
        Color = Albedo * 0.7;
    #else
        #if defined(_MAIN_LIGHT_SHADOWS_SCREEN) && !defined(_SURFACE_TYPE_TRANSPARENT)
            float4 shadowCoord = ComputeScreenPos(TransformWorldToHClip(PositionWS));
        #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
            float4 shadowCoord = TransformWorldToShadowCoord(PositionWS);
        #else
            float4 shadowCoord = float4(0, 0, 0, 0);
        #endif
        Light mainLight = GetMainLight(shadowCoord);
        Color = EvalMainLight(
            mainLight.direction, mainLight.color, mainLight.shadowAttenuation, mainLight.distanceAttenuation,
            PositionWS, NormalWS, ViewDirWS,
            Albedo, Metallic, Smoothness,
            ShadowThreshold, ShadowSmoothness, ShadowColor,
            SpecularStrength, SpecularColor,
            SpecularThreshold, SpecularSmoothness);
    #endif
}

void StylizedAdditionalLights_float(
    float3 PositionWS,
    float3 NormalWS,
    float3 ViewDirWS,
    float3 Albedo,
    float  Metallic,
    float  Smoothness,
    half4  Shadowmask,
    float  ShadowThreshold,
    float  ShadowSmoothness,
    float3 ShadowColor,
    float  SpecularStrength,
    float3 SpecularColor,
    float  SpecularThreshold,
    float  SpecularSmoothness,
    out float3 Color)
{
    Color = float3(0.0, 0.0, 0.0);
    #ifdef SHADERGRAPH_PREVIEW
        Color = float3(1.0, 1.0, 1.0);
    #else
        Color = float3(0.0, 0.0, 0.0);
        #if defined(_ADDITIONAL_LIGHTS)
        #if USE_CLUSTER_LIGHT_LOOP
            UNITY_LOOP for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
            {
                Light light = GetAdditionalLight(lightIndex, PositionWS, Shadowmask);
                Color += EvalAdditionalLight(
                    light.direction, light.color, light.distanceAttenuation, light.shadowAttenuation,
                    lightIndex, PositionWS, NormalWS, ViewDirWS,
                    Albedo, Metallic, Smoothness,
                    ShadowThreshold, ShadowSmoothness, ShadowColor,
                    SpecularStrength, SpecularColor, SpecularThreshold, SpecularSmoothness);
            }
        #endif
        
    
        InputData inputData = (InputData)0;
        float4 screenPos = ComputeScreenPos(TransformWorldToHClip(PositionWS));
        inputData.normalizedScreenSpaceUV = screenPos.xy / screenPos.w;
        inputData.positionWS = PositionWS;
        
        uint pixelLightCount = GetAdditionalLightsCount();
        LIGHT_LOOP_BEGIN(pixelLightCount)
            Light light = GetAdditionalLight(lightIndex, PositionWS, Shadowmask);
            Color += EvalAdditionalLight(
                light.direction, light.color, light.distanceAttenuation, light.shadowAttenuation,
                lightIndex, PositionWS, NormalWS, ViewDirWS,
                Albedo, Metallic, Smoothness,
                ShadowThreshold, ShadowSmoothness, ShadowColor,
                SpecularStrength, SpecularColor, SpecularThreshold, SpecularSmoothness);
        LIGHT_LOOP_END
        
        #endif
    #endif
}
#endif // SG_PAOPEAW_LIGHTING_SG_INCLUDED
