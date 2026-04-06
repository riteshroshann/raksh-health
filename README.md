# Raksh Health Engineering Specification

## Abstract
Raksh Health is a high-fidelity, AI-native health management platform architected for the Indian healthcare ecosystem. The system facilitates the secure aggregation, parsing, and visualization of fragmented medical records into a centralized, actionable health vault.

---

## Technical Architecture

### Frontend Layer
- **Framework**: Flutter with Riverpod 3.x for declarative state management.
- **Design System**: Ethereal Glassmorphism—a spatial UI implementation utilizing multi-layer BackdropFilters and high-sigma Gaussian blurs to maintain a premium, trust-centric user experience.
- **Typography**: Playfair Display (Serif) for semantic hierarchy and Plus Jakarta Sans (Geometric) for data-intensive UI components.

### Backend Infrastructure
- **Persistence**: PostgreSQL hosted on Supabase, leveraging PostgREST for high-performance API access.
- **Security**: Granular Row Level Security (RLS) policies scoped by `auth.uid` to ensure strict tenant isolation.
- **Notifications**: Dedicated service layer for local scheduling and Firebase Cloud Messaging (FCM) integration.

### Intelligence Pipeline
- **OCR**: Strategic integration with Google Cloud Vision for initial document digitization.
- **Clinical Extraction**: Claude 3.5 Sonnet-driven LLM pipeline for structured parsing of prescriptions, lab reports, and doctor clinical notes into normalized JSON schemas.

---

## Core System Modules

- **Diagnostic Vault**: Secure storage for laboratory reports (Tests) and radiological scans (Scans).
- **Medication Management**: Intelligent proactive tracking of active and historical prescriptions.
- **Clinical Consults**: Centralized repository for longitudinal doctor visit history and prescriptions.

---

## Documentation & Roadmap

For a comprehensive breakdown of the development timeline, feature completion metrics, and the upcoming engineering roadmap, refer to the project status documentation.

- **Status Report**: [PROJECT_STATUS.md](file:///d:/dev/raksh/docs/status/project_status.md)
- **Current Completion**: 68%
- **Architecture Integrity**: Stable

---

## License & Compliance
This repository is maintained with strict adherence to data privacy protocols. Enterprise-grade encryption and secure relational scoping are enforced by default.
