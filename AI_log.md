AI_LOG.md
Project: persons-finder-devops

Objective: Containerize, secure, and deploy the persons-finder Spring Boot app using Docker, Kubernetes, and GitHub Actions with AI-assisted design and CI verification.

1. Prompt: K8s Deployment

Prompt:

I asked ChatGPT: "Write a K8s deployment for a Spring Boot app."

Flaw Identified:

Pods ran as root.

No resource requests or limits.

Missing readiness/liveness probes.

No secrets handling for OPENAI_API_KEY.

Fix Applied:

Added securityContext (runAsUser, runAsGroup).

Added CPU/memory requests and limits.

Added readinessProbe and livenessProbe.

Mounted OPENAI_API_KEY as a Kubernetes Secret.

2. Prompt: HPA Configuration

Prompt:

I asked ChatGPT: "Add a HorizontalPodAutoscaler for the deployment."

Flaw Identified:

AI suggested unrealistic CPU values (e.g., 400 CPUs).

Fix Applied:

Set minReplicas: 2, maxReplicas: 6

Target CPU utilization: 60%

Verified metrics-server is running.

3. Prompt: Ingress & Network Security

Prompt:

I asked ChatGPT: "Add ingress and block all unnecessary egress traffic."

Flaw Identified:

Deprecated annotation kubernetes.io/ingress.class.

Egress block YAML incomplete.

Fix Applied:

Replaced with spec.ingressClassName.

Added NetworkPolicy to deny all external traffic except DNS and sidecar proxy.

Verified ingress controller (ingress-nginx) is running.

4. Prompt: PII Redaction / Gateway Logic

Prompt:

I asked ChatGPT: "Implement a PII Redaction Sidecar or Gateway to prevent real names from leaving the cluster."

AI Design:

Sidecar container scrubs name and bio before outbound requests.

Alternatively, a gateway interceptor could enforce redaction.

Human Decision / Fix:

Implemented sidecar pattern:

Each pod has a redaction container.

Outbound traffic passes through sidecar.

Documented in ARCHITECTURE.md with diagram.

5. Dockerfile

Prompt:

I asked ChatGPT: "Write a multi-stage Dockerfile for the Spring Boot app with Gradle build."

Flaws Identified:

Alpine base caused network/dependency issues.

Gradle wrapper missing → GradleWrapperMain errors.

Built as root.

Fix Applied:

Ubuntu-based builder (gradle:8.5-jdk17) and runtime (eclipse-temurin:17-jre-jammy).

Copied Gradle wrapper properly, made executable.

Non-root user added (appuser:appgroup).

Multi-stage build, container-aware JVM flags.

6. GitHub Actions CI

Prompt:

I asked ChatGPT: "Write a CI workflow for Gradle build + Trivy scan."

Flaws Identified:

AI tried to run ./gradlew without wrapper → failed.

Did not account for filesystem vs image scan.

Fix Applied:

Added chmod +x ./gradlew.

Build + test steps included.

Docker image built from multi-stage Dockerfile.

Trivy image + optional filesystem scan included.

Workflow fails on HIGH/CRITICAL vulnerabilities.

Outcome:

Trivy detected multiple HIGH/CRITICAL vulnerabilities in Java dependencies.

CI pipeline failed the build → prevented insecure code deployment.

7. Egress Security

Prompt:

I asked ChatGPT: "Block all egress traffic except necessary API calls."

Flaws Identified:

Initial deny-all blocked DNS and intra-cluster traffic.

Fix Applied:

Allowed DNS and sidecar proxy traffic.

Denied all other outbound external traffic.

8. Lessons Learned

AI accelerates scaffolding but human verification is mandatory.

Verified every AI suggestion for security, correctness, and best practices.

CI/CD is hardened with fail-fast Trivy checks.

9. High-Level Architecture Diagram
   ┌────────────────────────┐
   │   Ingress-NGINX        │
   └─────────┬──────────────┘
   │ HTTP/HTTPS
   ▼
   ┌────────────────────────┐
   │  Spring Boot App Pod   │
   │                        │
   │  ┌───────────────┐     │
   │  │ App Container │     │
   │  └───────────────┘     │
   │                        │
   │  ┌───────────────┐     │
   │  │ PII Sidecar   │     │
   │  │ (Redaction)   │     │
   │  └───────────────┘     │
   └─────────┬──────────────┘
   │ Outbound (Filtered)
   ▼
   External LLM API

Description:

Ingress routes external requests to the app pod.

Each pod contains a Spring Boot app and a PII redaction sidecar.

NetworkPolicy restricts all outbound traffic except to the sidecar/required services.

HPA auto-scales pods based on CPU usage.

OPENAI_API_KEY injected via Kubernetes Secret.

10. Summary Table
    Step	AI Output	Human Fix / Verification
    Deployment YAML	Root user, no limits	Added securityContext, resource limits, readinessProbe
    HPA	Unrealistic CPU	Fixed min/max replicas and CPU utilization
    Ingress	Deprecated annotation	Updated ingressClassName and verified webhook
    Egress / NetworkPolicy	Deny-all too aggressive	Allowed DNS, sidecar; blocked external traffic
    Dockerfile	Alpine / missing wrapper / root	Ubuntu multi-stage, non-root, Gradle wrapper fixed
    CI workflow	Wrapper missing / Trivy	Added wrapper chmod, build, tests, Trivy scan, fail on HIGH/CRIT
    PII Redaction	None	Added sidecar container for outbound data redaction

Result:

Fully working local + CI build

Secure runtime (non-root, resource-limited)

Autoscaling with HPA

Ingress + NetworkPolicy + PII redaction sidecar

CI workflow fails on vulnerabilities