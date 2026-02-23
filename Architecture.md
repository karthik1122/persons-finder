                ┌─────────────────────────┐
                │        Internet         │
                │   (api.openai.com)      │
                └────────────▲────────────┘
                             │
                     HTTPS (TLS 1.2+)
                             │
                ┌────────────┴────────────┐
                │   Egress Gateway /      │
                │   NAT / Firewall        │
                └────────────▲────────────┘
                             │
                ┌────────────┴────────────┐
                │  Service Mesh (Istio)   │
                │  or Egress Controller   │
                └────────────▲────────────┘
                             │
                ┌────────────┴────────────┐
                │ persons-finder Pods     │
                │ (Kubernetes Deployment) │
                └─────────────────────────┘