using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;

public class RF_CustomSSAO : ScriptableRendererFeature
{
    [SerializeField] RF_CustomSSAOSettings settings = new RF_CustomSSAOSettings();
    RF_CustomSSAOPass m_ScriptablePass;
    static readonly int SSAOColorID = Shader.PropertyToID("_SSAOColor");

    public override void Create()
    {
        m_ScriptablePass = new RF_CustomSSAOPass(settings)
        {
            renderPassEvent = RenderPassEvent.BeforeRenderingOpaques
        };
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (settings.material == null) return;
        renderer.EnqueuePass(m_ScriptablePass);
        Shader.SetGlobalColor(SSAOColorID, settings.color);
    }

    [Serializable]
    public class RF_CustomSSAOSettings
    {
        public Material material;
        public Color color;
    }

    class RF_CustomSSAOPass : ScriptableRenderPass
    {
        static readonly int s_SSAOTextureID = Shader.PropertyToID("_ScreenSpaceOcclusionTexture");
        readonly RF_CustomSSAOSettings settings;

        public RF_CustomSSAOPass(RF_CustomSSAOSettings settings)
        {
            this.settings = settings;
        }

        private class PassData
        {
            public TextureHandle ssaoInput;
            public Material material;
        }

        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            var resourceData = frameData.Get<UniversalResourceData>();

            if (!resourceData.ssaoTexture.IsValid())
                return;

            var desc = renderGraph.GetTextureDesc(resourceData.ssaoTexture);
            desc.name = "_CustomSSAO_Result";
            desc.clearBuffer = false;
            TextureHandle processedSSAO = renderGraph.CreateTexture(desc);

            using (var builder = renderGraph.AddRasterRenderPass<PassData>("Custom SSAO Post", out var passData))
            {
                passData.ssaoInput = resourceData.ssaoTexture;
                passData.material = settings.material;

                builder.UseTexture(passData.ssaoInput, AccessFlags.Read);
                builder.SetRenderAttachment(processedSSAO, 0, AccessFlags.Write);

                builder.SetGlobalTextureAfterPass(processedSSAO, s_SSAOTextureID);

                builder.SetRenderFunc((PassData data, RasterGraphContext ctx) =>
                {
                    Blitter.BlitTexture(ctx.cmd, data.ssaoInput, new Vector4(1, 1, 0, 0), data.material, 0);
                });
            }
        }
    }
}
