# Work Report & Design Decisions

## 1. Introduction

The goal of this project was to design and implement a database for a Film Festival Management System. The system needs to handle festivals, categories, films, people (actors/directors), staff, judges, screenings, and evaluations. I also built a simple web GUI to interact with the database and visualize the results of various SQL queries.

## 2. Database Design & EER Modeling

The core of this project is the relational schema. I spent a lot of time creating suitable
tables to meet the project needs, normalizing the tables to 3NF to avoid data redundancy,
adding sample data (with AI), creating documentation and report and creating a responsive web-based GUI for easy access.

### EER Specialization (Person, Staff, Judge)

One of the most important design decisions was how to handle people. In a real festival, a person might be an actor in a film, a judge for a different festival, or staff.

Instead of putting all these attributes into one massive `Person` table with a bunch of NULL columns, I used **EER Specialization**.

- `Person` is the base entity containing general info (name, birthdate).
- `Staff` and `Judge` are specialized subtypes linked to `Person` via foreign keys.

This is an **Overlapping Specialization** because the same `person_id` can exist in both the `Staff` and `Judge` tables simultaneously. This keeps the tables clean and allows for role-specific attributes (like `expertise` for judges or `department` for staff).

### Many-to-Many Relationships

I used junction tables to resolve all Many-to-Many relationships:

- **`FilmPerson`**: Connects films to people. It includes a `role_type` attribute to specify if the person is a 'director' or 'actor'.
- **`FilmJudge`**: Assigns judges to specific films. This separates the _assignment_ of a judge from the actual _evaluation_ (scoring).
- **`FestivalCategory`**: Maps which categories belong to which festival, allowing different festivals to have different rules.

## 3. Data Integrity and Constraints

To ensure the data remains clean, I heavily SQLite constraints:

- **Foreign Keys:** I enabled `PRAGMA foreign_keys = ON` at the top of the schema. This was crucial during testing; it caught several bugs where I accidentally tried to insert a `person_id` into a column that expected a `staff_id`.
- **CHECK Constraints:** Used to restrict values. For example, `role_type IN ('director', 'actor')` and `score >= 0 AND score <= 10`.
- **UNIQUE Constraints:** Applied to combinations like `(film_id, judge_id, criterion)` in the `Evaluation` table to ensure a judge can't accidentally submit two scores for the exact same criterion on the same film.

## 4. Query Implementation

I bypassed Django's ORM entirely and used `django.db.connection` in db_operations to
execute raw SQL for Read operations and I removed models.py which is the main schema
creation file in Django framework and instead used schema.sql for Write operations
(schema + sample data).

### Advanced Queries

Beyond basic `JOIN` and `GROUP BY` statements, I implemented a few advanced queries:

1. **Scheduling Conflicts:** I wrote a query that joins the `Screening` table to itself to find overlapping time slots in the same venue. This required using SQLite's `datetime()` math functions.
2. **Window Functions:** For the "Top Films Per Category" query, I used a Common Table Expression (CTE) combined with `RANK() OVER (PARTITION BY ...)` to rank films within their specific categories.
3. **Unrated Films:** Instead of a standard `LEFT JOIN ... WHERE IS NULL`, I used `WHERE NOT EXISTS (...)` for better performance and readability when finding films with zero evaluations.

## 5. Challenges & Debugging

Here are a couple of things I had to fix:

- **Gunicorn and Static Files:** Initially, my CSS and JS files weren't loading. I realized that unlike Django's development server, Gunicorn doesn't serve static files by default. I fixed this by integrating `WhiteNoise` middleware, which is the industry standard for serving static assets in production Django apps.
- **Foreign Key Mismatches:** When populating the `Screening` table, I initially used `person_id` for the `organizer_id` column. Because `PRAGMA foreign_keys` was on, SQLite threw an error. I needed to double-check whether a column expects the auto-generated primary key of the child table (`staff_id`) or the parent table (`person_id`).

## 6. AI Usage

I used AI tools to help me with repetitive tasks during the development of this project.
AI generated initial documentation drafts and created the sample dataset for the database. All AI-generated content has been reviewed, edited, and verified by me to ensure technical accuracy and alignment with the project description. The core database design, SQL query logic, all SQL commands and application architecture are my own work.

## 7. Project Milestones & Workflow

Here is a step-by-step breakdown of how the project was developed from start to finish:

- **Phase 1: Conceptual Design & Normalization:** I started by analyzing the Project Description (PD) and writing down the required fields for each entity on paper. Once the initial attributes were defined, I normalized the tables to 3NF and mapped out the relationships (1:N and M:N) between them.
- **Phase 2: EER Modeling & Visualization:** I drafted the text-based EER model in a `modeling.txt` file. I then used AI to convert this text into DBML and fed it into dbdiagram.io to generate the final visual ER/EER diagram (`modeling.pdf`).
- **Phase 3: Schema Implementation:** I created the `schema.sql` file and wrote the raw SQL commands to build the database structure, ensuring all primary keys, foreign keys, and constraints were properly defined.
- **Phase 4: Data Population:** I provided my `schema.sql` to AI to generate a baseline of sample data. I manually reviewed all the generated data, edited it to fix foreign key mismatches, and ensured it covered all edge cases. Finally, I wrote the finalized `INSERT` statements into `schema.sql`.
- **Phase 5: Query Development:** I wrote the SQL logic in `db_operations.py`. I initially implemented the 16 mandatory queries required by the PD. After finishing those, I added 4 more queries just for the fun of it to see what else the schema could handle.
- **Phase 6: Containerization & GUI:** I wrote the `Dockerfile` and `docker-compose.yml` to containerize the application. I also built a simple, interactive GUI using vanilla HTML, CSS, and JS to make testing the queries easier. Since the main focus of this project is database design, I won't go into deep detail about the frontend or Docker implementation.
- **Phase 7: Adding Additional Sample Data:** After testing the application, I realized some queries does not return any records (which is OK), but I wanted otherwise, so I added additional sample data in another section at the end of the schema.sql.
- **Phase 8: Configuration & Deployment:** I included the `.env` file in the final project output so that you can run the project immediately without needing to manually configure environment variables. _Note: I am fully aware that committing a `.env` file with secret keys is a fatal security error in a real-world production environment, but it was done here purely for the sake of easy evaluation and setup._
