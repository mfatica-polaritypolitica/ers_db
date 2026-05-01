# What the ERS stack actually needs

## Components

- PostgreSQL
  - Always on; approx. 20 tables
  - Moderate writes during scraper runs
  - Read-heavy for API and dashboard
- Scrapers
  - Short-lived cron jobs
  - No persistent compute needed
  - Will need to decide how often you want scrapers to run
- Scoring engine
  - Pure pandas/numpy arithmetic on Postgres data
  - CPU only
- API
  - Lightweight read-only service
  - One small container is sufficient
- Dashboard
  - Visualizes scored data

# Option O-Fully Free Stack

## Pros

- Completely free
- Sufficient to demo the full ERS stack to stakeholders

## Cons

- Render free API spins down after 15 minutes of inactivity
- Storage limit (Neon) will need upgrading as data grows
- No uptime SLA on any free tier
  - Not suitable for production or regulated use

## Links

- Neon (Postgres): neon.tech
- Render (API): [render.com](http://render.com)

## Monthly Cost breakdown

| **Component**                | **Monthly Cost** | **Notes**                                                                |
| ---------------------------- | ---------------- | ------------------------------------------------------------------------ |
| Neon (Postgres)              | 0                | Free tier: 0.5GB, serverless, no expiry                                  |
| ---                          | ---              | ---                                                                      |
| Render (API)                 | 0                | Free tier: 750 hrs/month, spins down on inactivity                       |
| ---                          | ---              | ---                                                                      |
| GitHub Actions (cron runner) | 0                | 2,000 free mins/month<br><br>Triggers scrapers and scoring on a schedule |
| ---                          | ---              | ---                                                                      |
| Cloudflare (dashboard)       | 0                | Free tier: a CloudFlare developer page                                   |
| ---                          | ---              | ---                                                                      |
| **Total**                    | **0**            |                                                                          |
| ---                          | ---              | ---                                                                      |

# Option A-Single VPS

## Pros

- Entire stack in one box
- Hetzner CX22 (2 vCPU, 4 GB RAM, £4/month) comfortably handles Postgres + a small FastAPI/Flask service + cron
- Full SSH access; simple to debug and maintain
- Can upgrade to a larger instance or migrate to Option B at any time with minimal disruption

## Cons

- OS updates, Postgres backups, and uptime have to managed manually
- No automatic failover, if the box goes down, everything is unavailable
- Not great if multiple team members need independent deployments

## Links

- Hetzner Cloud (VPS): <https://www.hetzner.com/cloud>
- Vercel (dashboard hosting, free tier): <https://vercel.com>
- Cloudflare (free TLS + CDN): <https://www.cloudflare.com>

## Monthly Cost breakdown

| **Component**     | **Monthly Cost** | **Notes**                                          |
| ----------------- | ---------------- | -------------------------------------------------- |
| Hetzner CX22 VOS  | £4-£6            | 2 vCPU, 4GB RAM<br><br>Runs full stack comfortably |
| ---               | ---              | ---                                                |
| Automated backups | £1               | Hetzner snapshot or restic to object storage       |
| ---               | ---              | ---                                                |
| Dashboard hosting | 0                | Vercel or Cloudflare Pages free tier               |
| ---               | ---              | ---                                                |
| Domain + TLS      | £1-£2            | Cloudflare TLS, cheap domain                       |
| ---               | ---              | ---                                                |
| **Total**         | **£6-£9**        |                                                    |
| ---               | ---              | ---                                                |

# Option B-Managed Postgres + PaaS

## Pros

- Managed Postgres handles backups, PITR, connection pooling, and patching automatically
- API and cron jobs deploy via git push on Render or Railway
  - No server management
- Scales smoothly
  - Can add more scraper jobs or increase scoring frequency without touching infrastructure

## Cons

- Some vendor dependency on chosen PaaS provider
- Starter-tier services may sleep between requests, causing occasional cold-start latency on the API

## Links

- Supabase (managed Postgres): <https://supabase.com/pricing>
- Neon (alternative managed Postgres): <https://neon.tech>
- Render (API + cron jobs): <https://render.com>
- Railway (alternative PaaS): <https://railway.app>
- Vercel (dashboard): <https://vercel.com>

## Monthly Cost Breakdown

| **Component**                | **Monthly Cost** | **Notes**                                                    |
| ---------------------------- | ---------------- | ------------------------------------------------------------ |
| Supabase Pro (Postgres)      | £20              | 8GB DB, PITR, connection pooling, daily backups              |
| ---                          | ---              | ---                                                          |
| Render/Railway (API service) | £7-£15           | Always-on starter web service, 512MB RAM                     |
| ---                          | ---              | ---                                                          |
| Render/Railway (cron jobs)   | 0-£10            | Scraper + scoring scheduled jobs; free tier covers light use |
| ---                          | ---              | ---                                                          |
| Dashboard (Vercel)           | 0                | Free tier: static or Nex.js frontend                         |
| ---                          | ---              | ---                                                          |
| **Total**                    | **£27-£45**      | More expensive as job frequency or data volume increases     |
| ---                          | ---              | ---                                                          |

# Option C-Fly.io containers

## Pros

- Everything runs as Docker containers
  - Consistent local and production environments
- Fly Machines scale to zero when idle
  - Scraper and scoring containers cost nothing between scheduled runs
- Fly Postgres provides managed cluster with automatic failover
- Deployable from CI/CD with flyctyl
  - Runs in the London region for low latency to UK gov.uk APIs

## Cons

- Slightly higher initial setup complexity
- Fly Postgres is self-managed on Fly infrastructure
  - Less fully managed than Supabase
- Per-second compute billing can be harder to predict if job runtimes vary

## Links

- Fly.io (containers + managed Postgres + cron): <https://fly.io>
- Vercel (dashboard): <https://vercel.com>

## Monthly Cost Breakdown

| **Component**                     | **Monthly Cost** | **Notes**                                             |
| --------------------------------- | ---------------- | ----------------------------------------------------- |
| Fly Postgres (shared-cpu-2x, 4GB) | £10-£15          | Adequate for ERS at current and near-future scale     |
| ---                               | ---              | ---                                                   |
| API (shared-cpu-1x, 256 MB)       | £3-£7            | Scales to zero<br><br>Billed per second of actual use |
| ---                               | ---              | ---                                                   |
| Scraper + scoring machines        | £2-£8            | Short-lived<br><br>Near-zero cost between runs        |
| ---                               | ---              | ---                                                   |
| Dashboard (Vercel)                | 0                | Static frontend on free tier                          |
| ---                               | ---              | ---                                                   |
| **Total**                         | **£15-£30**      |                                                       |
| ---                               | ---              | ---                                                   |

# Option D-AWS, GCP, Azure

## Pros

- Enterprise SLAs and compliance certifications
- Appropriate if ERS data is consumed by a regulated, client-facing product
- Can handle very scraper frequency, large organization counts, many concurrent API consumers
- There are free trials for these options to test them out

## Cons

- Most expensive options
- Requires cloud expertise to configure and maintain securely
- Vendor lock-in
- Overkill for current internal tooling

## Links

- AWS: <https://aws.amazon.com> (RDS + ECS Fargate + EventBridge + Lambda + CloudFront)
- Google Cloud; <https://cloud.google.com> (Cloud SQL + Cloud Run + Cloud Scheduler)
- Microsoft Azure: <https://azure.microsoft.com> (Flexible Server + App Service + Logic Apps)

## Monthly Cost Breakdown

| **Component**                      | **Monthly Cost** | **Notes**                                          |
| ---------------------------------- | ---------------- | -------------------------------------------------- |
| RDS PostgreSQL (db.t3.medium)      | £50 - £80        | Adequate for ERS at current and near-future scale  |
| ---                                | ---              | ---                                                |
| ECS Fargate (API, 0.5 vCPU / 1 GB) | £25 - £55        | Auto-scaling<br><br>pay per task-second            |
| ---                                | ---              | ---                                                |
| EventBridge + Lambda (cron jobs)   | £5 - £20         | Scrapers and scoring engine as scheduled functions |
| ---                                | ---              | ---                                                |
| CloudFront + S3 (dashboard)        | £5 - £20         | Static hosting with global CDN                     |
| ---                                | ---              | ---                                                |
| CloudWatch, Secrets Manager, misc  | £20 - £55        | Monitoring, alerting, secrets management           |
| ---                                | ---              | ---                                                |
| **Total**                          | **£105-£230**    |                                                    |
| ---                                | ---              | ---                                                |
