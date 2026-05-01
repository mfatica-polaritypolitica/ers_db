This repo contains everything needed to deploy a live version of the dashboard that is connected to the demo model. 

The models folder contains the same set of code as the table creator repo. The historical data contains the collected demo data used in the model. There is one CSV per table within the database schema as outlined in the initial dataset framework document. As with the other repo, load_csv.py loads all the CSVs into the SQL database. ers_db_dump.sql is the database in its current form that can be uploaded to a new SQL database. 

ers_scoring.py is the initial model for the Enforcement Risk Score, a weighted composite index that takes all six components to provide one clear score for clients. The ers_calibration.ipybnb (a Jupyter notebook file) should be used to further calibrate the model as more data is collected in order to ensure the best fit. api.py is the API code that connects the model to the dashboard, it is currently connected to the free stack outlined in the hosting server (Neon, Render, Cloudflare) but can be modified. 

index.html is the source code that creates the dashabord that is connected to the model through the API. The markdown file provides more guidance on how to integrate the model and API into the dashboard on a local device.
