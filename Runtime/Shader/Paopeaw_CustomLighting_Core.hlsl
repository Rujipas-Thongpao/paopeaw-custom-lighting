#ifndef PAOPEAW_CUSTOM_LIGHTING_CORE_INCLUDED
#define PAOPEAW_CUSTOM_LIGHTING_CORE_INCLUDED

float3 EvalMainLight(
    float3 direction, float3 color, float shadowAttenuation, float distanceAttenuation,
    float3 positionWS, float3 normalWS, float3 viewWS,
    float3 albedo, float smoothness, float metallic,
    float  shadowThreshold,    float  shadowSmoothness,   float3 shadowColor,
    float  specularStrength,   float3 specularColor,
    float  specularThreshold,  float  specularSmoothness)
{
    half3 V     = viewWS;
    half3 L = direction;
    half3 N = normalWS;
    half3 H     = normalize(V + L);
    half  NdotL = dot(N, L) * 0.5 + 0.5;

    float shadow = saturate(color * shadowAttenuation * distanceAttenuation * NdotL);

    half shadowEdge = smoothstep(
        shadowThreshold - shadowSmoothness,
        shadowThreshold + shadowSmoothness,
        shadow);
    shadowEdge += step(shadowThreshold + shadowSmoothness - 0.01, shadow) * color;

    half3 shadowTint = (1.0h - shadow) * shadowColor;

    half3 diffuse = color * albedo;

    half3 specF0 = lerp(half3(0.04h, 0.04h, 0.04h), albedo, metallic);
    half  gloss  = exp2(smoothness * 10.0h + 1.0h);
    half  NdotH  = saturate(dot(N, H));
    half3 spec   = pow(NdotH, gloss) * specF0;
    spec = smoothstep(
        specularThreshold - specularSmoothness * 0.5,
        specularThreshold + specularSmoothness * 0.5,
        spec);
    spec *= color * specularStrength * specularColor;

    return spec + diffuse * shadowEdge + shadowTint;
}

float3 EvalAdditionalLight(
    float3 L,          float3 lightColor,  float distanceAtten,     float shadowAtten,
    int    lightIndex, float3 positionWS,  float3 N, float3 viewWS,
    float3 albedo,     float  metallic,    float  smoothness,
    float  shadowThreshold,    float  shadowSmoothness,  float3 shadowColor,
    float  specularStrength,   float3 specularColor,
    float  specularThreshold,  float  specularSmoothness)
{
    half3 V     = viewWS;
    half3 H     = normalize(V + L);
    half  NdotL = dot(N, L);

    float shadow = saturate(shadowAtten * NdotL);

    half3 diffuse = lightColor * albedo;

    half3 specF0 = lerp(half3(0.04h, 0.04h, 0.04h), albedo, metallic);
    half  gloss  = exp2(smoothness * 10.0h + 1.0h);
    half  NdotH  = saturate(dot(N, H));
    half3 spec   = pow(NdotH, gloss) * specF0;

    spec = smoothstep(
        specularThreshold - specularSmoothness * 0.5,
        specularThreshold + specularSmoothness * 0.5,
        spec);
    spec *= lightColor * specularStrength * specularColor;

    return (diffuse * shadow + spec) * distanceAtten;
}


float3 AccumAdditionalLights(
    float3 positionWS, float3 normalWS, float3 viewDirectionWS, float4 shadowMask,
    float3 albedo, float3 metallic, float3 smoothness,
    float shadowThreshold,        float shadowSmoothness,        float3 shadowColor,
    float specularStrength,       float3 specularColor,
    float specularThreshold,      float  specularSmoothness)
{
    float3 lighting = 0.0;

    #if defined(_ADDITIONAL_LIGHTS)

    #if USE_CLUSTER_LIGHT_LOOP
    UNITY_LOOP for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
    {
        Light additionalLight = GetAdditionalLight(lightIndex, positionWS, shadowMask);
        lighting += EvalAdditionalLight(
            additionalLight.direction, additionalLight.color,
            additionalLight.distanceAttenuation, additionalLight.shadowAttenuation,
            lightIndex, positionWS, normalWS, viewDirectionWS,
            albedo, metallic, smoothness,
            shadowThreshold, shadowSmoothness, shadowColor,
            specularStrength, specularColor, specularThreshold, specularSmoothness);
    }
    #endif

    InputData inputData = (InputData)0;
    float4 screenPos = ComputeScreenPos(TransformWorldToHClip(positionWS));
    inputData.normalizedScreenSpaceUV = screenPos.xy / screenPos.w;
    inputData.positionWS              = positionWS;
    uint pixelLightCount = GetAdditionalLightsCount();
    LIGHT_LOOP_BEGIN(pixelLightCount)
        Light light = GetAdditionalLight(lightIndex, positionWS, shadowMask);
        #ifdef _LIGHT_LAYERS
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        #endif
        {
            lighting += EvalAdditionalLight(
                light.direction, light.color,
                light.distanceAttenuation, light.shadowAttenuation,
                lightIndex, positionWS, normalWS, viewDirectionWS,
                albedo, metallic, smoothness,
                shadowThreshold, shadowSmoothness, shadowColor,
                specularStrength, specularColor, specularThreshold, specularSmoothness);
        }
    LIGHT_LOOP_END

    #endif

    return lighting;
}
#endif // CUSTOM_LIGHTING_CORE_INCLUDED
