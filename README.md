# 🛡️ Raksh Health - AI-Native Healthcare Platform

**Raksh Health** is a sophisticated, patient-first health management platform designed for the Indian healthcare ecosystem. It bridges the gap between fragmented medical records and intelligent, actionable health insights.

---

## 🚀 Key Features

- **Health Vault**: Secure, glass-morphic document management system.
- **AI Diagnosis Pipeline**:
    - **OCR**: Integrated Google Cloud Vision for precise document text extraction.
    - **Extraction**: Claude 3.5 Sonnet-powered clinical parsing (Lab Reports, Prescriptions, Doctor Notes).
- **Relational Sync**: Automatic structured data entry into Lab Results and Medication trackers.
- **Secure Auth**: Dual-method authentication (Phone OTP + Google Sign-In).

---

## 🧠 Technology Stack

- **Frontend**: Flutter (Riverpod 3.x, Custom Glassmorphism).
- **Backend**: Supabase (PostgreSQL, Edge Functions).
- **AI Models**: 
    - Google Cloud Vision (OCR).
    - Claude 3.5 Sonnet (Information Extraction).
- **Storage**: Supabase Secure Storage with Relational Scoping (`auth.uid -> profile_id`).

---

## 🛠️ Development Setup

1. **Environment Variables**:
   Ensure the following are set in your Supabase project:
   - `GOOGLE_CLOUD_VISION_API_KEY`
   - `ANTHROPIC_API_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY`

2. **Flutter Configuration**:
   - Update `lib/config/supabase_config.dart` with your project URL and Anon Key.

---

## 📄 License & Privacy

Your data is private and encrypted by default. Built for the modern, safety-conscious patient.
