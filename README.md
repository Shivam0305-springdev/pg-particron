# PostgreSQL Particron Engine (pg-particron)

A production-ready PostgreSQL base image pre-configured with **pg_cron** and **pg_partman** for automated time-series partitioning and background job scheduling.

This image dynamically configures the extensions at startup, meaning your team can change the database name and user accounts without breaking the background workers.

---

## 🛠️ Local Setup & Build

1. Clone or navigate into this directory:
   ```bash
   cd pg-particron
   ```

2. Build the Docker image locally:
   ```bash
   docker build -t postgres-particron:15 .
   ```

---

## 🚀 How to Use It

Users can spin up a container using standard PostgreSQL environment variables. The initialization script will automatically inject the configuration and install the extensions into the chosen database.

### Option A: Quick Start (Default Database & User)
```bash
docker run -d \
  --name pg-automated \
  -e POSTGRES_PASSWORD=mysecurepassword \
  -p 5432:5432 \
  postgres-particron:15
```
* **Database Created:** `postgres`
* **User Created:** `postgres`

### Option B: Custom Configuration (Advanced)
```bash
docker run -d \
  --name pg-automated \
  -e POSTGRES_DB=analytics_prod \
  -e POSTGRES_USER=dbadmin \
  -e POSTGRES_PASSWORD=mysecurepassword \
  -p 5432:5432 \
  postgres-particron:15
```
* **Database Created:** `analytics_prod`
* **User Created:** `dbadmin`

---

## 🧪 Verifying the Installation

Connect to your database instance and run the following commands to confirm everything works.

### 1. Check Extensions
List the installed extensions to confirm `pg_cron` and `pg_partman` are active:
```sql
\dx
```

### 2. Verify Background Worker Config
Confirm that the active configuration file correctly points to your current database:
```sql
SHOW cron.database_name;
```

### 3. Test `pg_cron` Automation
Schedule a lightweight test job that executes every minute:
```sql
SELECT cron.schedule('health-check-job', '* * * * *', 'SELECT 1');
```
Wait 60 seconds, then check the internal logs to verify successful executions:
```sql
SELECT * FROM cron.job_run_details;
```

---

## 📦 Project Structure
```text
pg-particron/
├── Dockerfile              # Builds packages and sets up shared libraries
├── setup-extensions.sh     # Shell script handling dynamic restarts and SQL injection
└── README.md               # This setup guide
```
