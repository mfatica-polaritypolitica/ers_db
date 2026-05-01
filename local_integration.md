**Software needed**

| **Software**       | **Check it's installed**  | **Download from**       |
| ------------------ | ------------------------- | ----------------------- |
| Python 3.10+       | python3 --version         | python.org/downloads    |
| PostgreSQL         | psql --version            | postgresql.org/download |
| DBeaver (optional) | For viewing data visually | dbeaver.io              |

**What's in the zip**

| **File**                  | **What it does**                                                     |
| ------------------------- | -------------------------------------------------------------------- |
| api.py                    | The API server - reads the database and serves data to the dashboard |
| ers_scoring.py            | The scoring engine - computes the Enforcement Risk Score             |
| load_csvs.py              | Loads all the historical CSV data into your PostgreSQL database      |
| reg1-dashboard-fixed.html | The dashboard - open this in your browser                            |
| models/                   | Database model files - do not edit these                             |
| historical data/          | All the historical CSV data files                                    |
| requirements.txt          | Python package list - installed in Step 2                            |

**Setup steps**

**FIRST TIME ONLY**

| **1** | **Unzip and move to the project folder**<br><br>cd /path/to/unzipped/folder<br><br>_→ Replace /path/to/unzipped/folder with wherever you unzipped the files. On Mac: drag the folder into Terminal._ |
| ----- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

| **2** | **Install Python dependencies (once only)**<br><br>pip install -r requirements.txt<br><br>_→ This installs all the libraries the API needs. Takes about 1 minute._ |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |

| **3** | **Create a PostgreSQL database**<br><br>psql -U postgres -c "CREATE DATABASE ers*db;"<br><br>*→ You only need to do this once. If asked for a password, use your PostgreSQL password.\_ |
| ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

| **4** | **Fill in your database password**<br><br>Open the .env file in any text editor and replace YOURPASSWORD with your PostgreSQL password<br><br>_→ The file contains one line: DATABASE_URL=postgresql://postgres:YOURPASSWORD@localhost:5432/ers_db_ |
| ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

| **5** | **Load the historical data into the database**<br><br>python load*csvs.py --truncate<br><br>*→ Reads all the CSV files and loads them into PostgreSQL. Takes 1-2 minutes. You should see a row count summary at the end.\_ |
| ----- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

| **6** | **Run the scoring engine**<br><br>python ers*scoring.py --backfill<br><br>*→ Computes the Enforcement Risk Scores from the data. Takes 30-60 seconds.\_ |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |

✓ Setup is complete. Steps 1-6 only need to be done once.

**Running the dashboard**

**EVERY TIME YOU WANT TO USE THE DASHBOARD**

_You need two Terminal windows open at the same time._

**Terminal window 1:**

| **7** | **Start the API server - keep this window open**<br><br>uvicorn api:app --reload --port 8000<br><br>_→ You should see: INFO: Uvicorn running on <http://127.0.0.1:8000>_ |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |

**Terminal window 2 (open a new one with Cmd+T):**

| **8** | **Serve the dashboard - keep this window open too**<br><br>python -m http.server 3000 |
| ----- | ------------------------------------------------------------------------------------- |

**In your browser:**

| **9** | **Open the dashboard**<br><br><http://localhost:3000/reg1-dashboard-fixed.html><br><br>_→ Copy and paste this address into Chrome or Safari. Do not double-click the HTML file._ |
| ----- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

✓ The dashboard should load with live data. If a red error banner appears at the top, the API in Terminal 1 is not running.

⚠ To stop: press Ctrl+C in each Terminal window.

**Updating the data**

When new CSV data is available, run these two commands to update the scores:

python load_csvs.py --truncate

python ers_scoring.py --backfill

**Common problems**

| **Problem**                          | **Fix**                                                                  |
| ------------------------------------ | ------------------------------------------------------------------------ |
| Red error banner on dashboard        | API is not running. Go back to Step 7.                                   |
| 'No module named uvicorn'            | Run Step 2 again: pip install -r requirements.txt                        |
| 'connection refused' on health check | PostgreSQL is not running. Start it with: brew services start postgresql |
| Dashboard shows wrong company name   | Go to: localhost:3000/reg1-dashboard-fixed.html?reset=1                  |
| 'could not import models'            | Make sure you are running commands from the project folder (Step 1).     |
| Port 8000 already in use             | Run: lsof -ti:8000 \| xargs kill then retry Step 7.                      |

_Questions? Contact Marta Fatica._
