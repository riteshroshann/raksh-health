import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // 1. Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { document_id, file_url } = await req.json();

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const googleApiKey = Deno.env.get("GOOGLE_CLOUD_VISION_API_KEY")!;

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 2. Call Google Cloud Vision API
    const visionResponse = await fetch(
      `https://vision.googleapis.com/v1/images:annotate?key=${googleApiKey}`,
      {
        method: "POST",
        body: JSON.stringify({
          requests: [
            {
              image: { source: { imageUri: file_url } },
              features: [{ type: "DOCUMENT_TEXT_DETECTION" }],
            },
          ],
        }),
      }
    );

    const result = await visionResponse.json();
    const fullText = result.responses[0]?.fullTextAnnotation?.text || "";

    if (!fullText) throw new Error("Could not extract text from document.");

    // 3. Update the documents table
    const { error: updateError } = await supabase
      .from("documents")
      .update({
        ocr_text: fullText,
        processing_status: "ocr_done",
      })
      .eq("id", document_id);

    if (updateError) throw updateError;

    return new Response(JSON.stringify({ success: true, ocr_text: fullText }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});
