# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package Overview

`com.pathong.paopeawcustomlighting` (v1.0.6) is a Unity 6 URP custom package providing toon/stylized lighting HLSL utilities for both hand-written shaders and Shader Graph. Requires `com.unity.render-pipelines.universal` 17.3.0.

## HLSL Architecture

The lighting logic is split across three HLSL files under `Runtime/Shader/`:

- **`Paopeaw_CustomLighting_Core.hlsl`** — Pure math, no URP boilerplate. Contains `EvalMainLight`, `EvalAdditionalLight`, and `AccumAdditionalLights`. This is the shared core that both the hand-written shader and Shader Graph wrapper include.
- **`Paopeaw_CustomLighting_SG.hlsl`** — Shader Graph–facing wrapper. Includes `_Core.hlsl` and exposes `StylizedMainLight_float` / `StylizedAdditionalLights_float` as custom function nodes. Handles `SHADERGRAPH_PREVIEW` stubs and forward-pass keyword pragmas.
- **`CustomLighting.hlsl`** — Fork of [Cyanilux's URP_ShaderGraphCustomLighting](https://github.com/Cyanilux/URP_ShaderGraphCustomLighting) for Unity 6.1+. Provides generic utility functions (`MainLight_float`, `MainLightShadows_float`, `AdditionalLights_float`, `AdditionalLightsToon_float`, `ToonAttenuation`, `Shadowmask_half`, `MixFog_float`, `AmbientSampleSH_float`) that are independent of the Paopeaw toon model. Kept separate so the Cyanilux utilities can still be used standalone.

**`shd_unlit_pbr.shader`** is the primary hand-written shader (`Techart/Paopeaw/shd_unlit_pbr`). Its ForwardLit pass calls `EvalMainLight` + `AccumAdditionalLights` directly from `_Core.hlsl`. Other passes (ShadowCaster, GBuffer, DepthOnly, DepthNormals, Meta, MotionVectors) delegate to URP's stock Lit passes via `LitInput.hlsl`.

### Toon lighting model (in `_Core.hlsl`)
- `EvalMainLight`: half-Lambert NdotL, stepped shadow via `smoothstep` + threshold/smoothness, SSS approximation via a second `smoothstep` band, stepped Blinn-Phong specular.
- `EvalAdditionalLight`: similar stepped specular, Schlick metallic F0 blend, combined diffuse+spec with distance attenuation.
- `AccumAdditionalLights`: iterates Forward+ cluster loop + `LIGHT_LOOP_BEGIN/END`.

### Shader Graph subgraphs (`Runtime/Shader/SSG/`)
Each `.shadersubgraph` isolates one concept: `SGG_MainLight`, `SGG_AdditionalLights`, `SGG_Simple_Lit`, `SSG_Albedo`, `SSG_Fresnel`, `SSG_Specular`, `SSG_SSAO`, `SSG_SampleAPV`, `SSS_RimLight`, `SSG_Fog`, `SSG_HalfAngle`, `SSG_NormalWS`, `SSG_MainLightShadow`, `SSG_Ambient_Basic`, `SSG_GetMainLight`. The top-level `SG_Simple_Lit.shadergraph` composes these.

## Shader Material Properties

`shd_unlit_pbr.shader` uses a **MOSE map** (not MODS): R=Metallic, G=Occlusion, B=Smoothness, A=Emissive. Property groups: Base, Lighting (AmbientStrength), Shadow (threshold/smoothness/color/SSS), Specular (strength/color/threshold/smoothness), Fresnel, Rim Light.

## Package Structure

```
Runtime/Shader/          # HLSL source + shadersubgraphs
Editor/                  # EditorExample.cs (boilerplate placeholder)
Samples/Example/         # Sample materials + baked scene (SampleScene.unity)
Tests/Editor|Runtime/    # Placeholder test files
```

## Versioning

Increment `"version"` in `package.json` for every release. `CHANGELOG.md` follows Keep a Changelog / SemVer.

## Shader Graph usage note

To use the stylized lighting in Shader Graph, include `Paopeaw_CustomLighting_SG.hlsl` as a Custom Function node (File mode). The required multi-compile pragmas are guarded by `SHADERPASS` checks inside the file to avoid duplicate-keyword warnings when nested in a Lit Graph.
