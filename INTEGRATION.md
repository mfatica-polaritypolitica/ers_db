# REG-1 Dashboard — Backend Integration Guide

## What this file is

`api.py` is a FastAPI server that sits between your PostgreSQL database (populated
by your ERS Python models) and the `reg1-dashboard.pages.dev` frontend.

---

## Architecture

```
reg1-dashboard.pages.dev  (Cloudflare Pages — your frontend)
          │
          │  HTTPS GET requests
          ▼
  api.py  (FastAPI — this file)
          │
          │  SQLAlchemy queries
          ▼
  PostgreSQL  (your ers_db — populated by ERS ingestion pipelines)
          │
          ├── legislative_models.py   → l1_bills, l2_statutory_instruments
          ├── regulatory_models.py    → r1–r6 ICO/regulator tables
          ├── judicial_models.py      → j1–j4 court tables
          ├── political_models.py     → p1–p6 political tables
          ├── ico_volume_models.py    → i1–i2 ICO volume tables
          └── media_models.py         → m1–m2 NGO / press tables
```

---

## Endpoints the dashboard calls

| Endpoint | What it powers |
|---|---|
| `GET /api/v1/score` | Enforcement probability gauge (70–85 range) |
| `GET /api/v1/alerts` | Live alerts panel (Critical / Elevated cards) |
| `GET /api/v1/signals` | Signal sources tab (all 18 sources) |
| `GET /api/v1/timeline` | Timeline tab (milestone dates) |
| `GET /api/v1/budget-signal` | ICO budget widget (↑ +23%) |
| `GET /api/v1/force-date` | Days-to-force countdown |
| `GET /api/v1/health` | Liveness / DB connectivity check |

---

## Setup

### 1. Install dependencies

```bash
pip install fastapi uvicorn sqlalchemy psycopg2-binary python-dotenv
```

### 2. Set your database URL

Create a `.env` file next to `api.py`:

```
DATABASE_URL=postgresql://your_user:your_password@your_host:5432/ers_db
```

### 3. Make sure all model files are importable

Put `api.py` in the same directory as:
- `legislative_models.py`
- `regulatory_models.py`
- `judicial_models.py`
- `political_models.py`
- `ico_volume_models.py`
- `media_models.py`

Or adjust the import paths at the top of `api.py` to match your package structure.

### 4. Run the API

```bash
uvicorn api:app --reload --port 8000
```

Visit `http://localhost:8000/docs` for the interactive Swagger UI.

---

## Wiring it into the dashboard

In the dashboard's frontend code, find where it calls the backend (look for
`fetch(...)` calls or a config file with an API base URL). Replace the base URL
with your deployed API address.

For example, if the dashboard has something like:

```js
const API_BASE = "https://api.reg1.yourdomain.com";

const score = await fetch(`${API_BASE}/api/v1/score?company_sector=hiring`);
const alerts = await fetch(`${API_BASE}/api/v1/alerts`);
```

The `company_sector` query parameter lets you filter results by sector
(hiring, healthcare, fintech, etc.) once you wire that into your DB queries.

---

## Deployment options

### Option A — Railway / Render (simplest)
1. Push `api.py` + model files to GitHub
2. Connect the repo to Railway or Render
3. Set `DATABASE_URL` as an environment variable
4. The platform auto-runs `uvicorn api:app --host 0.0.0.0 --port $PORT`

### Option B — Docker
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY . .
RUN pip install fastapi uvicorn sqlalchemy psycopg2-binary python-dotenv
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Option C — Same server as your DB
```bash
# As a systemd service or screen session
uvicorn api:app --host 0.0.0.0 --port 8000 --workers 2
```

---

## CORS

The API already allows requests from `https://reg1-dashboard.pages.dev`.
If you deploy to a custom domain, add it to the `allow_origins` list in `api.py`:

```python
allow_origins=[
    "https://reg1-dashboard.pages.dev",
    "https://your-custom-domain.com",   # ← add this
    "http://localhost:3000",
]
```

---

## One thing to check: R3IcoConsultations field names

`api.py` references `R3IcoConsultations.consultation_close` and
`R3IcoConsultations.key_obligations` — check that these match the exact
column names in your `regulatory_models.py` (the file you shared was
truncated at line 175 so I couldn't confirm). Adjust if needed.

---

## Next steps

1. **Run the health check first**: `curl http://localhost:8000/api/v1/health`
2. **Check the score endpoint**: `curl "http://localhost:8000/api/v1/score?company_sector=hiring"`
3. **Wire the dashboard**: find the API base URL config in the frontend and point it here
4. **Share the frontend source** if you want help writing the exact `fetch()` calls
