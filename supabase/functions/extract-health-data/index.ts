import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { document_id, ocr_text, category, profile_id } = await req.json();

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const anthropicApiKey = Deno.env.get("ANTHROPIC_API_KEY")!;

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 1. Call Claude API (Anthropic)
    const promptMap = {
      'Lab Report': 'extract { report_date, lab_name, tests: [{test_name, value, unit, ref_range, flag}] }',
      'Prescription': 'extract { doctor_name, hospital, date, medicines: [{name, dose, frequency, duration}] }',
      'Doctor Note': 'extract { doctor_name, hospital, date, diagnosis, notes, follow_up_date }',
      'Default': 'extract { date, summary, key_findings }',
    };

    const targetFormat = promptMap[category] || promptMap['Default'];

    const anthropicResponse = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": anthropicApiKey,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: "claude-3-5-sonnet-20240620",
        max_tokens: 4096,
        system: "You are a medical document parser for Indian health records. Extract structured data from OCR text. Return ONLY valid JSON, no explanation.",
        messages: [
          {
            role: "user",
            content: `Document Category: ${category}\nTarget JSON Format: ${targetFormat}\n\nOCR Text:\n${ocr_text}`,
          },
        ],
      }),
    });

    const anthropicResult = await anthropicResponse.json();
    const extractionContent = anthropicResult.content[0].text;
    const extractionJson = JSON.parse(extractionContent);

    // 2. Update documents table
    await supabase
      .from("documents")
      .update({
        extraction_json: extractionJson,
        processing_status: "completed",
      })
      .eq("id", document_id);

    // 3. Relational Inserts based on category
    if (category === 'Lab Report' && extractionJson.tests) {
      const tests = extractionJson.tests.map((t: any) => ({
        profile_id,
        test_name: t.test_name,
        test_value: t.value || t.test_value,
        unit: t.unit,
        reference_range: t.ref_range || t.reference_range,
        document_id,
      }));
      await supabase.from("lab_results").insert(tests);
    } else if (category === 'Prescription' && extractionJson.medicines) {
      const medicines = extractionJson.medicines.map((m: any) => ({
        profile_id,
        medicine_name: m.name || m.medicine_name,
        dosage: m.dose || m.dosage,
        frequency: m.frequency,
        duration: m.duration,
        document_id,
      }));
      await supabase.from("medicines").insert(medicines);
    }

    return new Response(JSON.stringify({ success: true, extraction: extractionJson }), {
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
