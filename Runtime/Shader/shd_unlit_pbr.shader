Shader "Techart/Paopeaw/shd_unlit_pbr"
{
    Properties
    {
        [Header(Base)]
        [Space(4)]
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _NormalStrength ("Normal Strength", Range(0,10)) = 0.5
        _MOSEMap ("MOSE Map (R=Metallic, G=Occlusion, B=Smoothness, A=Emissive)", 2D) = "white" {}
        _MetallicStrength  ("Metallic",  Range(0,1)) = 1.0
        _OcclusionStrength ("Occlusion", Range(0,1)) = 1.0
        _SmoothnessStrength("Smoothness", Range(0,1)) = 0.5
        _EmissionColor     ("Emission Color", Color) = (0,0,0,1)
        _EmissionStrength  ("Emission Strength", Float) = 1.0

        [Space(8)]
        [Header(Lighting)]
        [Space(4)]
        _AmbientStrength ("Ambient Strength", Float) = 0.1

        [Space(8)]
        [Header(Shadow)]
        [Space(4)]
        _ShadowThreshold  ("Shadow Threshold",  Range(0,1)) = 0.5
        _ShadowSmoothness ("Shadow Smoothness", Range(0,1)) = 0.0
        _ShadowColor      ("Shadow Color", Color) = (0, 0, 0, 0)
        _SSSStrength      ("SSS Strength", Float) = 0.3

        [Space(8)]
        [Header(Specular)]
        [Space(4)]
        _SpecularStrength   ("Specular Strength",   Float)      = 1.0
        _SpecularColor      ("Specular Color",      Color)      = (1,1,1,1)
        _SpecularThreshold  ("Specular Threshold",  Range(0,1)) = 0.5
        _SpecularSmoothness ("Specular Smoothness", Range(0,1)) = 0.0

        [Space(8)]
        [Header(Fresnel)]
        [Space(4)]
        _FresnelColor      ("Fresnel Color",      Color)      = (1,1,1,1)
        _FresnelStrength   ("Fresnel Strength",   Float)      = 1.0
        _FresnelThreshold  ("Fresnel Threshold",  Range(0,1)) = 0.8
        _FresnelSmoothness ("Fresnel Smoothness", Range(0,1)) = 0.1

        [Space(8)]
        [Header(Rim Light)]
        [Space(4)]
        _RimColor      ("Rim Color",      Color)      = (1,1,1,1)
        _RimStrength   ("Rim Strength",   Float)      = 1.0
        _RimThreshold  ("Rim Threshold",  Range(0,1)) = 0.5
        _RimSmoothness ("Rim Smoothness", Range(0,1)) = 0.1
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
        }

        // =====================================================================
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON _ALPHAMODULATE_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _SPECULAR_SETUP

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            // #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile _ _FORWARD_PLUS
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ PROBE_VOLUMES_L1 PROBE_VOLUMES_L2
            #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/AmbientOcclusion.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"
            #include "./Paopeaw_CustomLighting_Core.hlsl"
            

            // -------------------------------------
            // Vertex input / output
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
                float2 uv2        : TEXCOORD1;  // lightmap UV
                float4 normal     : NORMAL;
                float4 tangent    : TANGENT;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float3 normalWS     : TEXCOORD1;
                half3  tangentWS    : TEXCOORD2;
                half3  bitangentWS  : TEXCOORD3;
                float3 positionWS   : TEXCOORD4;
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 5); // TEXCOORD5
                #ifdef DYNAMICLIGHTMAP_ON
                float2 dynamicLightmapUV : TEXCOORD6;
                #endif
                float  fogCoord       : TEXCOORD7;
                half4  probeOcclusion : TEXCOORD8;
            };

            // -------------------------------------
            // Textures
            TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);
            TEXTURE2D(_MOSEMap);   SAMPLER(sampler_MOSEMap);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);

            // -------------------------------------
            // Per-material constants
            CBUFFER_START(UnityPerMaterial)
                // Base
                half4  _BaseColor;
                float4 _BaseMap_ST;
                float  _NormalStrength;
                half   _MetallicStrength;
                half   _OcclusionStrength;
                half   _SmoothnessStrength;
                half4  _EmissionColor;
                half   _EmissionStrength;

                // Lighting
                float  _AmbientStrength;

                // Shadow
                float  _ShadowThreshold;
                float  _ShadowSmoothness;
                float4 _ShadowColor;
                float  _SSSStrength;

                // Specular
                float  _SpecularStrength;
                float4 _SpecularColor;
                float  _SpecularThreshold;
                float  _SpecularSmoothness;

                // Fresnel
                float4 _FresnelColor;
                float  _FresnelStrength;
                float  _FresnelThreshold;
                float  _FresnelSmoothness;

                // Rim Light
                float4 _RimColor;
                float  _RimStrength;
                float  _RimThreshold;
                float  _RimSmoothness;
            CBUFFER_END

            float4 GetShadowCoord(float3 positionWS)
            {
                #if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                    return TransformWorldToShadowCoord(positionWS);
                #else
                    return float4(0, 0, 0, 0);
                #endif
            }

            float3 InitialializeBakedGI(Varyings IN, InputData inputData)
            {
                float3 bakedGI = (float3)0;
                #if defined(_SCREEN_SPACE_IRRADIANCE)
                    bakedGI = SAMPLE_GI(0, IN.positionWS);
                #elif defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)
                    bakedGI = SAMPLE_GI(IN.staticLightmapUV, IN.dynamicLightmapUV, IN.vertexSH, inputData.normalWS);
                #elif defined(DYNAMICLIGHTMAP_ON)
                    bakedGI = SAMPLE_GI(IN.staticLightmapUV, IN.dynamicLightmapUV, IN.vertexSH, inputData.normalWS);
                #elif defined(LIGHTMAP_ON)
                    bakedGI = SAMPLE_GI(IN.staticLightmapUV, IN.vertexSH, inputData.normalWS);
                #elif defined(PROBE_VOLUMES_L1) || defined(PROBE_VOLUMES_L2)
                    bakedGI = SAMPLE_GI(IN.vertexSH,
                        GetAbsolutePositionWS(inputData.positionWS),
                        inputData.normalWS,
                        inputData.viewDirectionWS,
                        inputData.positionCS.xy,
                        IN.probeOcclusion,
                        inputData.shadowMask);
                #else
                    bakedGI = SAMPLE_GI(IN.staticLightmapUV, IN.vertexSH, inputData.normalWS);
                #endif
                return bakedGI;
            }

            // void APV_float(float3 positionWS, float3 normalWS, float3 viewDirWS, float2 positionSS, float renderingLayer, out float3 color)
            // {
            //     EvaluateAdaptiveProbeVolume(positionWS,normalWS,viewDirWS, positionSS, renderingLayer, color);
            // }
            
            float3 GetNormal(Varyings IN)
            {
                half3 normalTS = UnpackNormalScale(
                    SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, IN.uv),
                    _NormalStrength);
                float3 T      = normalize(IN.tangentWS);
                float3 B      = normalize(IN.bitangentWS);
                float3 N_surf = normalize(IN.normalWS);
                half3  N      = normalize(mul(normalTS, float3x3(T, B, N_surf)));
                return N;
            }
            // -------------------------------------
            // Vertex shader
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionWS  = TransformObjectToWorld(IN.positionOS);
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv          = TRANSFORM_TEX(IN.uv, _BaseMap);

                half3 normalWS    = (TransformObjectToWorldNormal(IN.normal));
                half3 tangentWS   = (TransformObjectToWorldDir(IN.tangent.xyz));
                half  tangentSign = IN.tangent.w * unity_WorldTransformParams.w;
                half3 bitangentWS = cross(normalWS, tangentWS) * tangentSign;

                OUT.normalWS    = normalWS;
                OUT.tangentWS   = tangentWS;
                OUT.bitangentWS = bitangentWS;

                OUTPUT_LIGHTMAP_UV(IN.uv2, unity_LightmapST, OUT.staticLightmapUV);
                #ifdef DYNAMICLIGHTMAP_ON
                OUT.dynamicLightmapUV = IN.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                #endif
                OUTPUT_SH4(OUT.positionWS, OUT.normalWS, GetWorldSpaceNormalizeViewDir(OUT.positionWS), OUT.vertexSH, OUT.probeOcclusion);
                OUT.fogCoord = ComputeFogFactor(OUT.positionHCS.z);
                return OUT;
            }
            
            half3 Fresnel(InputData inputData)
            {
                float fresnelAmount = 1.0-saturate(max(0,dot(normalize(inputData.normalWS), normalize(inputData.viewDirectionWS))));
                fresnelAmount = smoothstep(
                    _FresnelThreshold - _FresnelSmoothness,
                    _FresnelThreshold + _FresnelSmoothness,
                    fresnelAmount
                );
                fresnelAmount *= _FresnelColor * _FresnelStrength;
                return fresnelAmount;
            }
            
            half3 RimLight(InputData inputData, Light mainLight)
            {
                float NdotV = saturate(dot(normalize(inputData.normalWS), normalize(inputData.viewDirectionWS)));
                float NdotL = dot(normalize(inputData.normalWS), normalize(mainLight.direction)) + 0.2h;
                float rimAmount = (1.0 - NdotV) * (NdotL * 0.5 + 0.5);
                rimAmount = smoothstep(
                    _RimThreshold - _RimSmoothness,
                    _RimThreshold + _RimSmoothness,
                    rimAmount
                );
                return rimAmount * _RimColor.rgb * _RimStrength;
            }

            // -------------------------------------
            // Fragment shader
            half4 frag(Varyings IN) : SV_Target
            {
                half3 V       = GetWorldSpaceNormalizeViewDir(IN.positionWS);
                half3 N       = GetNormal(IN);
                half3 R       = reflect(-V, N);
                
                InputData inputData = (InputData)0;
                inputData.positionWS            = IN.positionWS;
                inputData.positionCS            = IN.positionHCS;
                inputData.normalWS              = N;
                inputData.viewDirectionWS       = V;
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.positionHCS);
                inputData.shadowMask            = SAMPLE_SHADOWMASK(IN.staticLightmapUV);
                inputData.shadowCoord           = GetShadowCoord(IN.positionWS);
                inputData.bakedGI               = InitialializeBakedGI(IN, inputData);

                half4 mose      = SAMPLE_TEXTURE2D(_MOSEMap, sampler_MOSEMap, IN.uv);
                half  metallic   = mose.r * _MetallicStrength;
                half  occlusion  = lerp(1.0, mose.g, _OcclusionStrength);
                half  smoothness = mose.b * _SmoothnessStrength;
                half  emission   = mose.a * _EmissionStrength * _EmissionColor;

                float4 baseTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                half3  albedo  = baseTex.rgb * _BaseColor.rgb;
                float  alpha   = baseTex.a;

                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo     = albedo;
                surfaceData.metallic   = metallic;
                surfaceData.smoothness = smoothness;
                surfaceData.occlusion  = occlusion;
                surfaceData.emission   = emission;

                Light mainLightData = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
                float3 mainLight = EvalMainLight(
                    mainLightData.direction, mainLightData.color, mainLightData.shadowAttenuation, mainLightData.distanceAttenuation,
                    inputData.positionWS, inputData.normalWS, inputData.viewDirectionWS,
                    surfaceData.albedo, surfaceData.smoothness, surfaceData.metallic,
                    _ShadowThreshold, _ShadowSmoothness, _ShadowColor.rgb, _SSSStrength,
                    _SpecularStrength, _SpecularColor.rgb,
                    _SpecularThreshold, _SpecularSmoothness
                );

                float3 additionalLight = AccumAdditionalLights(
                    inputData.positionWS,inputData.normalWS, inputData.viewDirectionWS, inputData.shadowMask,
                     surfaceData.albedo, surfaceData.metallic, surfaceData.smoothness,
                    _ShadowThreshold, _ShadowSmoothness, _ShadowColor.rgb,
                    _SpecularStrength, _SpecularColor.rgb,
                    _SpecularThreshold, _SpecularSmoothness);
                
                AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(inputData.normalizedScreenSpaceUV);
                half ssaoIndirect = aoFactor.indirectAmbientOcclusion;
                half ssaoDirect   = aoFactor.directAmbientOcclusion;

                half3 ambient = inputData.bakedGI * occlusion * ssaoIndirect;
                // return half4(ambient,1.0);
                half3 reflection = GlossyEnvironmentReflection(R, inputData.positionWS, 1.0h);
                
                half3 rawAlbedo = albedo * (1.0 - surfaceData.metallic);
                albedo = rawAlbedo * mainLight;
                albedo += additionalLight;
                albedo += ambient * _AmbientStrength;
                albedo += reflection * _SpecularStrength * ssaoIndirect;
                albedo += Fresnel(inputData);
                albedo += RimLight(inputData, mainLightData);
                albedo += surfaceData.emission;
                albedo *= surfaceData.occlusion;
                albedo *= ssaoDirect * ssaoIndirect;

                if (alpha < 0.1)
                    discard;

                albedo = MixFog(albedo, IN.fogCoord);
                return half4(albedo, alpha);
            }

            ENDHLSL
        }

        // =====================================================================
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        // =====================================================================
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "GBuffer"
            Tags { "LightMode" = "UniversalGBuffer" }

            ZWrite[_ZWrite]
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 4.5
            // Deferred Rendering Path does not support the OpenGL-based graphics API:
            // Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
            #pragma exclude_renderers gles3 glcore
            #pragma vertex LitGBufferPassVertex
            #pragma fragment LitGBufferPassFragment
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            //#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitGBufferPass.hlsl"
            ENDHLSL
        }

        // =====================================================================
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask R
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }

        // =====================================================================
        // This pass is used when drawing to a _CameraNormalsTexture texture
        Pass
        {
            Name "DepthNormals"
            Tags { "LightMode" = "DepthNormals" }

            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"
            ENDHLSL
        }

        // =====================================================================
        // This pass is not used during regular rendering, only for lightmap baking.
        Pass
        {
            Name "Meta"
            Tags { "LightMode" = "Meta" }

            Cull Off

            HLSLPROGRAM
            #pragma target 2.0
            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaLit
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local_fragment _SPECGLOSSMAP
            #pragma shader_feature EDITOR_VISUALIZATION
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitMetaPass.hlsl"
            ENDHLSL
        }

        // =====================================================================
        Pass
        {
            Name "Universal2D"
            Tags { "LightMode" = "Universal2D" }

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
            ENDHLSL
        }

        // =====================================================================
        Pass
        {
            Name "MotionVectors"
            Tags { "LightMode" = "MotionVectors" }
            ColorMask RG

            HLSLPROGRAM
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma shader_feature_local_vertex _ADD_PRECOMPUTED_VELOCITY
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ObjectMotionVectors.hlsl"
            ENDHLSL
        }

        // =====================================================================
        Pass
        {
            Name "XRMotionVectors"
            Tags { "LightMode" = "XRMotionVectors" }
            ColorMask RGBA

            // Stencil write for obj motion pixels
            Stencil
            {
                WriteMask 1
                Ref 1
                Comp Always
                Pass Replace
            }

            HLSLPROGRAM
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma shader_feature_local_vertex _ADD_PRECOMPUTED_VELOCITY
            #define APLICATION_SPACE_WARP_MOTION 1
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ObjectMotionVectors.hlsl"
            ENDHLSL
        }
    }
}
