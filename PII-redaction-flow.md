                                   ┌──────────────────────────────┐
                                   │           Internet           │
                                   │  (External APIs, SaaS, etc.) │
                                   └───────────────▲──────────────┘
                                                   │
                                         HTTPS (443) Only
                                                   │
                                      ┌────────────┴────────────┐
                                      │     Egress Gateway      │
                                      │  (Envoy / Istio Gateway)│
                                      │--------------------------│
                                      │ • PII Redaction Engine   │
                                      │ • Field-based masking    │
                                      │ • Regex / NER detection  │
                                      │ • Tokenization option    │
                                      │ • Audit logging          │
                                      └────────────▲────────────┘
                                                   │
                                NetworkPolicy allows ONLY this path
                                                   │
┌─────────────────────────────────────────────────────────────────────────┐
│                         Kubernetes Cluster                              │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │                     persons-finder Pod                           │  │
│  │                                                                   │  │
│  │  ┌──────────────────────┐      localhost      ┌────────────────┐ │  │
│  │  │  Application         │ ───────────────────► │  PII Sidecar  │ │  │
│  │  │  (Business Logic)    │                      │  Proxy        │ │  │
│  │  │                      │                      │----------------│ │  │
│  │  │  Contains Real Names │                      │ • Intercepts   │ │  │
│  │  └──────────────────────┘                      │ • Redacts PII  │ │  │
│  │                                                │ • Forwards     │ │  │
│  │                                                └────────▲───────┘ │  │
│  └──────────────────────────────────────────────────────────│─────────┘  │
│                                                             │            │
│                      ❌ Direct Egress Blocked               │            │
│                      (Default Deny-All Policy)              │            │
└─────────────────────────────────────────────────────────────┼────────────┘
│
DNS Allowed (kube-dns only)