# Film Festival Management System

This is my final project for the Database Design course. It's a web-based management system for a film festival.

The Django ORM is bypassed and Django is only used for routing and serving the GUI.
All Database commands are written in raw SQL.

## Tech Stack

- **Backend:** Python, Django
- **Database:** SQLite3
- **Server:** Gunicorn (inside Docker)
- **Frontend:** Vanilla HTML/CSS/JS

## Features

### Database Design & Architecture

- **EER Modeling:** Implements Enhanced Entity-Relationship (EER) specialization.
- **Normalization:** The schema is normalized to 3NF.
- **Data Integrity:** Extensive use of `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, and `CHECK` constraints.
- **Performance Optimization:** Includes a comprehensive set of indexes on all foreign keys and frequently queried columns.

### Interactive GUI & Query Engine

- **Raw SQL Execution:** 20 custom SQL queries implemented using `django.db.connection`.
  16 were included in project description and 4 extra queries in db_operations.py and
  DB schema and sample data in schema.sql file.
- **Modern Web Interface:** A clean, responsive dashboard built with Vanilla HTML/CSS/JS. It uses AJAX to execute queries dynamically without reloading the page and renders results in scrollable, formatted tables.

## How to Run

The project is fully containerized using Docker and Docker Compose. You do not need to install Python, Django, or SQLite on your local machine.

### Prerequisites

- Windows: Docker Desktop installed and running.
- Linux: Docker Engine installed and running.

### Step-by-Step Instructions

1. **Clone or download** this repository to your local machine.
2. **Open your terminal** and navigate to the root directory of the project (where the `docker-compose.yml` file is located).
3. **Build and start the containers** by running:
   ```bash
   docker compose up --build
   ```
4. **Access the Application:** Open your web browser and go to:
   ```text
   http://127.0.0.1:8000/
   ```
5. **Interact with the Dashboard:** Click on any of the 20 queries in the list. If a query requires a parameter (like a Film ID or Date), enter it and click "Execute Query" to see the results.
6. **To Stop the Server:** Press `Ctrl + C` in your terminal, or run:
   ```bash
   docker compose down
   ```

## AI Usage

Artificial Intelligence (AI) tools were utilized during the development of this project to assist with generating initial documentation drafts and creating the sample dataset for the database. All AI-generated content has been reviewed, edited, and verified by me to ensure technical accuracy and alignment with the project's requirements.

## .env File

This is file is present in the project output because this is a simple university project
and the professor should have easy access to it without dealing with configurations.

## Project Structure (Important Files)

```text
film_festival/
├── festival_app/
│   ├── core/                   # Core app for configuration
│   │   └── db_operations.py    # SQL Read commands
│   ├── data/                   # Contains SQLite3 Database itself
│   ├── db_init/
│   │    └── schema.sql         # SQL Write commands (schema + sample data)
│   ├── main/                   # main app for GUI
│   └── static/                 # CSS/JS files
├── docs/                       # Documentation and reports
│   ├── WORK_REPORT.md          # Detailed design decisions
│   ├── modeling.txt            # EER/ER text documentation
│   ├── modeling.pdf            # EER/ER pdf documentation
│   ├── screenshots/            # Screenshots of query outputs
│   └── queries.txt             # All SQL code in one file
├── docker-compose.yml          # Docker container orchestration
├── Dockerfile                  # Main docker container
├── entrypoint.sh               # Entrypoint for main docker container
├── requirements.txt            # Project requirements
├── .env                        # This file exists on purpose
└── README.md

```

## Documentation

- **`docs/WORK_REPORT.md`:** Detailed explanation of the design decisions, EER modeling, and the challenges faced during development.
- **`docs/modeling.pdf`:** Visual representations of the database schema.
- **`docs/queries.txt`:** All the database commands used in this project
- **`docs/screenshots/`:** Screenshots of all query outputs
