import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function calculateReminderTimes(frequency: string): string[] {
  const freq = frequency.toLowerCase();
  if (freq.includes('once')) return ['08:00'];
  if (freq.includes('twice') || freq.includes('bd') || freq.includes('2')) return ['08:00', '20:00'];
  if (freq.includes('three') || freq.includes('tds') || freq.includes('3')) return ['08:00', '14:00', '20:00'];
  if (freq.includes('four') || freq.includes('qid') || freq.includes('4')) return ['08:00', '12:00', '16:00', '20:00'];
  return ['08:00'];
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { document_id, file_url, category, profile_id } = await req.json();

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const geminiApiKey = Deno.env.get("GEMINI_API_KEY")!;
    const anthropicApiKey = Deno.env.get("ANTHROPIC_API_KEY")!;

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 1. Fetch file and convert to base64
    const fileResponse = await fetch(file_url);
    const arrayBuffer = await fileResponse.arrayBuffer();
    const base64data = btoa(String.fromCharCode(...new Uint8Array(arrayBuffer)));

    // 2. Detect mimeType
    const extension = file_url.split('.').pop()?.toLowerCase() || '';
    let mimeType = "image/jpeg";
    if (extension === 'png') mimeType = "image/png";
    else if (extension === 'pdf') mimeType = "application/pdf";

    // 3. Call Gemini 1.5 Flash for OCR
    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`,
      {
        method: "POST",
        body: JSON.stringify({
          contents: [{
            parts: [
              { text: "Extract ALL text from this medical document exactly as written. Include all numbers, units, dates, doctor names, medicine names, test values. Return only the raw extracted text." },
              { inlineData: { mimeType: mimeType, data: base64data } }
            ]
          }]
        }),
      }
    );

    const geminiResult = await geminiResponse.json();
    const geminiText = geminiResult.candidates[0].content.parts[0].text;

    // 4. Update documents (Stage 1)
    await supabase.from("documents").update({
      ocr_text: geminiText,
      processing_status: "ocr_done",
    }).eq("id", document_id);

    // 5. Call Claude for Extraction
    const userPromptMap: Record<string, string> = {
      'Lab Report': `Extract from this text: { report_date: 'DD/MM/YYYY', lab_name: '', tests: [{test_name, value_numeric, unit, ref_low, ref_high, flag: 'HIGH/LOW/NORMAL', is_critical: bool}], confidence: 0.0-1.0 }\n\nText: ${geminiText}`,
      'Prescription': `Extract from this text: { doctor_name, hospital, date: 'DD/MM/YYYY', medicines: [{name, generic_name, dose, frequency, timing, duration_days}], diagnosis: [], next_visit, confidence: 0.0-1.0 }\n\nText: ${geminiText}`,
      'Doctor Note': `Extract from this text: { doctor_name, hospital, date, diagnosis, notes, follow_up_date, confidence: 0.0-1.0 }\n\nText: ${geminiText}`,
      'Default': `Extract from this text: { date, summary, key_findings: [], confidence: 0.0-1.0 }\n\nText: ${geminiText}`,
    };

    const anthropicResponse = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": anthropicApiKey,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: "claude-3-5-sonnet-20240620", // Using current stable Sonnet 3.5
        max_tokens: 2048,
        system: "You are a medical document parser for Indian health records. Extract structured data from OCR text. Return ONLY valid JSON, no explanation, no markdown.",
        messages: [{ role: "user", content: userPromptMap[category] || userPromptMap['Default'] }],
      }),
    });

    const anthropicResult = await anthropicResponse.json();
    let extractionText = anthropicResult.content[0].text;
    
    // Strip markdown if exists
    extractionText = extractionText.replace(/```json/g, "").replace(/```/g, "").trim();
    const parsedJson = JSON.parse(extractionText);

    // 6. Update documents (Stage 2)
    await supabase.from("documents").update({
      extraction_json: parsedJson,
      processing_status: "completed",
      extraction_confidence: parsedJson.confidence ?? 0.85,
    }).eq("id", document_id);

    // 7. Relational Inserts
    if (category === 'Lab Report' && parsedJson.tests) {
      const tests = parsedJson.tests.map((t: any) => ({
        profile_id,
        document_id,
        report_date: parsedJson.report_date,
        test_name: t.test_name,
        value_numeric: parseFloat(t.value_numeric),
        unit: t.unit,
        ref_low: parseFloat(t.ref_low),
        ref_high: parseFloat(t.ref_high),
        flag: t.flag,
        is_critical: t.is_critical ?? false,
      }));
      await supabase.from("lab_results").insert(tests);
    } else if (category === 'Prescription' && parsedJson.medicines) {
      const medicines = parsedJson.medicines.map((m: any) => ({
        profile_id,
        document_id,
        medicine_name: m.name,
        generic_name: m.generic_name,
        dose: m.dose,
        frequency: m.frequency,
        timing: m.timing,
        start_date: new Date().toISOString().split('T')[0],
        is_active: true,
        reminder_times: calculateReminderTimes(m.frequency),
      }));
      await supabase.from("medicines").insert(medicines);
    }

    return new Response(JSON.stringify({ success: true, ocr_text: geminiText, extraction: parsedJson }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    // Attempt to mark failure in DB
    try {
       const body = await req.json();
       if (body?.document_id) {
         const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
         const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
         const supabase = createClient(supabaseUrl, supabaseServiceKey);
         await supabase.from("documents").update({ processing_status: "failed" }).eq("id", body.document_id);
       }
    } catch {}

    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});
