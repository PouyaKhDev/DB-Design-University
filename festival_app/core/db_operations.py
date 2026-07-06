from django.db import connection

################################################
# Bypassing the Django ORM and executing raw SQL
# Each function is a single query
# Each function has 2 parts:
#  1. Executing the raw SQL query
#  2. Convert the response to a list of dictionaries and return it
################################################


def get_films_by_festival(festival_id):
    """A list of all films in a particular festival"""
    with connection.cursor() as cursor:
        # Raw SQL
        cursor.execute(
            """
            SELECT f.title, c.name AS category, f.country, f.release_year, f.duration_minutes
            FROM Film f
            JOIN Category c ON f.category_id = c.category_id
            WHERE f.festival_id = %s
        """,
            [festival_id],
        )

        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def count_films_by_category(category_id):
    """Number of films in a particular category"""
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT COUNT(*) AS film_count
            FROM Film
            WHERE category_id = %s
        """,
            [category_id],
        )
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_all_categories_with_film_count():
    """A list of all film categories with the number of films in them"""
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT c.name AS category, COUNT(f.film_id) AS film_count
            FROM Category c
            LEFT JOIN Film f ON c.category_id = f.category_id
            GROUP BY c.category_id, c.name
        """)
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_directors_of_film(film_id):
    """A list of all directors of a particular film"""
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT p.first_name, p.last_name
            FROM Person p
            JOIN FilmPerson fp ON p.person_id = fp.person_id
            WHERE fp.film_id = %s AND fp.role_type = 'director'
        """,
            [film_id],
        )
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_actors_of_film(film_id):
    """List all actors of a particular film with their role"""
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT p.first_name, p.last_name, fp.role_type
            FROM Person p
            JOIN FilmPerson fp ON p.person_id = fp.person_id
            WHERE fp.film_id = %s AND fp.role_type = 'actor'
        """,
            [film_id],
        )
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_future_screenings_of_film(film_id):
    """Future screenings of a particular film"""
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT f.title, s.screening_datetime, v.name AS venue_name, v.capacity,
                   p.first_name || ' ' || p.last_name AS organizer_name
            FROM Screening s
            JOIN Film f ON s.film_id = f.film_id
            JOIN Venue v ON s.venue_id = v.venue_id
            JOIN Staff st ON s.organizer_id = st.staff_id
            JOIN Person p ON st.person_id = p.person_id
            WHERE s.film_id = %s AND s.screening_datetime > datetime('now')
        """,
            [film_id],
        )
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_screenings_by_date(target_date):
    """All the screenings of a particular day (target_date format: 'YYYY-MM-DD')"""
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT f.title, s.screening_datetime, v.name AS venue_name,
                   p.first_name || ' ' || p.last_name AS organizer_name
            FROM Screening s
            JOIN Film f ON s.film_id = f.film_id
            JOIN Venue v ON s.venue_id = v.venue_id
            JOIN Staff st ON s.organizer_id = st.staff_id
            JOIN Person p ON st.person_id = p.person_id
            WHERE DATE(s.screening_datetime) = %s
        """,
            [target_date],
        )
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_films_with_screening_count():
    """A list of films with the number of their screenings ordered decreasingly"""
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT f.title, COUNT(s.screening_id) AS screening_count
            FROM Film f
            LEFT JOIN Screening s ON f.film_id = s.film_id
            GROUP BY f.film_id, f.title
            ORDER BY screening_count DESC
        """)
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_films_with_avg_overall_rating():
    """A list of all films with the average judges overall rating"""
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT f.title, AVG(e.score) AS avg_overall_rating
            FROM Film f
            JOIN Evaluation e ON f.film_id = e.film_id
            WHERE e.criterion = 'overall'
            GROUP BY f.film_id, f.title
        """)
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_films_with_avg_overall_rating_ordered():
    """A list of all films with their average judges overall rating ordered decreasingly"""
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT f.title, AVG(e.score) AS avg_overall_rating
            FROM Film f
            JOIN Evaluation e ON f.film_id = e.film_id
            WHERE e.criterion = 'overall'
            GROUP BY f.film_id, f.title
            ORDER BY avg_overall_rating DESC
        """)
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_avg_overall_rating_for_film(film_id):
    """Average judges overall rating for a particular film"""
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT f.title, AVG(e.score) AS avg_overall_rating
            FROM Film f
            JOIN Evaluation e ON f.film_id = e.film_id
            WHERE f.film_id = %s AND e.criterion = 'overall'
            GROUP BY f.film_id, f.title
        """,
            [film_id],
        )
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_unrated_films():
    """A list of names of the films that are not evaluated yet"""
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT f.title
            FROM Film f
            WHERE NOT EXISTS (
                SELECT 1 FROM Evaluation e WHERE e.film_id = f.film_id
            )
        """)
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_judges_with_more_than_5_evaluations():
    """
    Name and expertise of judges who evaluated more than 5 films
    with the number of films they evaluated
    """
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT p.first_name || ' ' || p.last_name AS judge_name, j.expertise,
                   COUNT(DISTINCT e.film_id) AS evaluated_film_count
            FROM Judge j
            JOIN Person p ON j.person_id = p.person_id
            JOIN Evaluation e ON j.judge_id = e.judge_id
            GROUP BY j.judge_id, p.first_name, p.last_name, j.expertise
            HAVING COUNT(DISTINCT e.film_id) > 5
        """)
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_films_with_more_than_1_director():
    """A list of the names of all films with more than 1 director"""
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT f.title, COUNT(fp.person_id) AS director_count
            FROM Film f
            JOIN FilmPerson fp ON f.film_id = fp.film_id
            WHERE fp.role_type = 'director'
            GROUP BY f.film_id, f.title
            HAVING COUNT(fp.person_id) > 1
        """)
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_actors_in_more_than_2_films():
    """A list of the names of all actors who acted in more than 2 films"""
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT p.first_name || ' ' || p.last_name AS actor_name,
                   COUNT(fp.film_id) AS film_count
            FROM Person p
            JOIN FilmPerson fp ON p.person_id = fp.person_id
            WHERE fp.role_type = 'actor'
            GROUP BY p.person_id, p.first_name, p.last_name
            HAVING COUNT(fp.film_id) > 2
        """)
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_venue_screening_count_by_date(target_date):
    """
    The venues names and number of all screenings held in each
    of them for a particular date
    """
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT v.name AS venue_name, COUNT(s.screening_id) AS screening_count
            FROM Venue v
            JOIN Screening s ON v.venue_id = s.venue_id
            WHERE DATE(s.screening_datetime) = %s
            GROUP BY v.venue_id, v.name
        """,
            [target_date],
        )
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_judges_who_havent_evaluated():
    """A list of judges names who has not evaluated a film yet"""
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT p.first_name || ' ' || p.last_name AS judge_name
            FROM Judge j
            JOIN Person p ON j.person_id = p.person_id
            LEFT JOIN Evaluation e ON j.judge_id = e.judge_id
            WHERE e.evaluation_id IS NULL
        """)
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_films_without_screenings():
    """A list of films names which does not have a screening"""
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT f.title
            FROM Film f
            LEFT JOIN Screening s ON f.film_id = s.film_id
            WHERE s.screening_id IS NULL
        """)
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_scheduling_conflicts():
    """Finds overlapping screenings in the same venue."""
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT v.name AS venue,
                   f1.title AS film_1, s1.screening_datetime AS time_1,
                   f2.title AS film_2, s2.screening_datetime AS time_2
            FROM Screening s1
            JOIN Screening s2 ON s1.venue_id = s2.venue_id AND s1.screening_id < s2.screening_id
            JOIN Film f1 ON s1.film_id = f1.film_id
            JOIN Film f2 ON s2.film_id = f2.film_id
            JOIN Venue v ON s1.venue_id = v.venue_id
            WHERE s1.screening_datetime < datetime(s2.screening_datetime, '+' || s2.duration_minutes || ' minutes')
              AND s2.screening_datetime < datetime(s1.screening_datetime, '+' || s1.duration_minutes || ' minutes')
        """)
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_top_films_per_category():
    """Ranks films within their category based on average overall rating."""
    with connection.cursor() as cursor:
        cursor.execute("""
            WITH FilmRatings AS (
                SELECT f.title, c.name AS category, AVG(e.score) AS avg_score
                FROM Film f
                JOIN Category c ON f.category_id = c.category_id
                JOIN Evaluation e ON f.film_id = e.film_id
                WHERE e.criterion = 'overall'
                GROUP BY f.film_id, f.title, c.name
            )
            SELECT title, category, avg_score,
                   RANK() OVER (PARTITION BY category ORDER BY avg_score DESC) as rank_in_category
            FROM FilmRatings
            ORDER BY category, rank_in_category
        """)
        columns = [col[0] for col in cursor.description]  # type: ignore
        return [dict(zip(columns, row)) for row in cursor.fetchall()]
