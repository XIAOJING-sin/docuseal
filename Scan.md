I finished scanning the repo end-to-end and built a high-level map of how DocuSeal works. Below is a concise overview of architecture, core data model, main flows, and integrations, with brief code references.
What this project is
DocuSeal: an open-source platform for building, filling, signing, and processing documents and PDFs, with APIs, webhooks, and a web UI.
Tech stack
Backend: Ruby on Rails (Rails 8 defaults), Sidekiq jobs, Devise (with 2FA), CanCanCan, ActiveStorage, HexaPDF.
Frontend: Turbo + custom web components, Vue 3 app for the template builder, Tailwind/DaisyUI.
Storage/Infra: ActiveStorage (local/S3/GCS/Azure), background jobs via Sidekiq, optional multi-tenant mode with different constraints.
Core domain model
Templates define forms and fields; Submissions are instances created from a Template; Submitters fill/sign; events and documents are persisted via ActiveStorage.
Key models and associations:
Routing and main surfaces
Dashboard/UI, public/guest form routes, and a JSON API namespace:
Auth and authorization
Web/UI via Devise; API via X-Auth-Token mapping to AccessToken (hashed SHA-256).
Authorization via CanCanCan (Ability in lib/ability.rb).
Template builder UI (Vue + Turbo)
A custom element mounts a Vue 3 app for WYSIWYG PDF form building.
Submission and signing flow
Create Submission from a Template; invite Submitters; fill/sign; on completion, PDFs and audit trail are generated and optionally signed server-side with configured PKCS/TSA; combined document is attached to Submission.
PDF tools (merge, verify) exposed via API.
Combined PDF generation and signing:
Webhooks
Event-driven webhooks with exponential backoff and health tracking; HTTPS-only and no localhost in multi-tenant mode.
Emails and notifications
SubmitterMailer handles invitations, completion, decline; dynamic templates/config; attachments are size-limited and include generated PDFs/audit trails when configured.
Multi-tenancy and configuration
Docuseal.multitenant? gates routes/constraints, URLs, and stricter webhook rules.
URL defaults, console/cdn URLs, PWA flag, and allowed locales configured centrally in lib/docuseal.rb and config/application.rb.
Background jobs
Jobs for webhooks, submission lifecycle (expired/completed), previews, and search indexing; Sidekiq mounted for admins when applicable.
External services and storage
ActiveStorage backends supported: S3, GCS, Azure (gems present in Gemfile) and local disk; API blob proxies are provided in the API namespace to serve/download securely.
If you want, I can drill into any specific flow (e.g., field conditions engine, formulas, payments, embedded SDKs, or the exact webhook payloads per event) and diagram it.
I completed a full scan and mapped the architecture. Next, I can deep-dive into any subsystem you care about (API usage examples, data model ERD, or specific extension points).