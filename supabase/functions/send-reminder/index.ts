import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.43.0"

serve(async (req) => {
  const { userId, medicineId, medicineName, dose, timing } = await req.json()

  // 1. Initialize Supabase Admin Client
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  // 2. Fetch User FCM Token
  const { data: profile } = await supabase
    .from('profiles')
    .select('fcm_token')
    .eq('user_id', userId)
    .single()

  if (!profile?.fcm_token) {
    return new Response(JSON.stringify({ error: 'No FCM token found for user' }), { status: 400 })
  }

  // 3. Send Notification using Firebase Cloud Messaging API
  // Note: For production, you should use the Firebase Admin SDK or a direct HTTP v1 call
  // This is a placeholder for the logic that interacts with Firebase
  const fcmUrl = 'https://fcm.googleapis.com/fcm/send'
  
  // LOGGING (as a placeholder for actual FCM call which requires service account JSON)
  await supabase.from('reminder_logs').insert({
    medicine_id: medicineId,
    fcm_token: profile.fcm_token,
    status: 'sent',
    payload: { medicineName, dose, timing }
  })

  return new Response(JSON.stringify({ success: true, token: profile.fcm_token }), { 
    headers: { "Content-Type": "application/json" } 
  })
})
