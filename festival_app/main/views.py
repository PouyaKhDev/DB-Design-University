import json

from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.http import require_POST
from django.views.decorators.csrf import ensure_csrf_cookie

from core import db_operations

# Query Metadata
QUERY_CONFIG = {
    "get_films_by_festival": {
        "title": "1. Films by Festival",
        "description": "List of all films in a particular festival.",
        "params": [{"name": "festival_id", "type": "number", "label": "Festival ID"}],
    },
    "count_films_by_category": {
        "title": "2. Films Count by Category",
        "description": "Number of films in a particular category.",
        "params": [{"name": "category_id", "type": "number", "label": "Category ID"}],
    },
    "get_all_categories_with_film_count": {
        "title": "3. All Categories with Film Count",
        "description": "A list of all film categories with the number of films in them.",
        "params": [],
    },
    "get_directors_of_film": {
        "title": "4. Directors of a Film",
        "description": "A list of all directors of a particular film.",
        "params": [{"name": "film_id", "type": "number", "label": "Film ID"}],
    },
    "get_actors_of_film": {
        "title": "5. Actors of a Film",
        "description": "A list of all actors of a particular film.",
        "params": [{"name": "film_id", "type": "number", "label": "Film ID"}],
    },
    "get_future_screenings_of_film": {
        "title": "6. Future Screenings of a Film",
        "description": "Future screenings of a particular film.",
        "params": [{"name": "film_id", "type": "number", "label": "Film ID"}],
    },
    "get_screenings_by_date": {
        "title": "7. Screenings by Date",
        "description": "All the screenings of a particular day.",
        "params": [
            {"name": "target_date", "type": "date", "label": "Date (YYYY-MM-DD)"}
        ],
    },
    "get_films_with_screening_count": {
        "title": "8. Films with Screening Count",
        "description": "A list of films with the number of their screenings ordered decreasingly.",
        "params": [],
    },
    "get_films_with_avg_overall_rating": {
        "title": "9. Films with Avg Overall Rating",
        "description": "A list of all films with the average judges overall rating.",
        "params": [],
    },
    "get_films_with_avg_overall_rating_ordered": {
        "title": "10. Films with Avg Rating (Ordered)",
        "description": "A list of all films with their average judges overall rating ordered decreasingly.",
        "params": [],
    },
    "get_avg_overall_rating_for_film": {
        "title": "11. Avg Rating for a Film",
        "description": "Average judges overall rating for a particular film.",
        "params": [{"name": "film_id", "type": "number", "label": "Film ID"}],
    },
    "get_unrated_films": {
        "title": "12. Unrated Films",
        "description": "A list of names of the films that are not evaluated yet.",
        "params": [],
    },
    "get_judges_with_more_than_5_evaluations": {
        "title": "13. Active Judges (>5 Films)",
        "description": "Name and expertise of judges who evaluated more than 5 films.",
        "params": [],
    },
    "get_films_with_more_than_1_director": {
        "title": "14. Films with >1 Director",
        "description": "A list of the names of all films with more than 1 director.",
        "params": [],
    },
    "get_actors_in_more_than_2_films": {
        "title": "15. Actors in >2 Films",
        "description": "A list of the names of all actors who acted in more than 2 films.",
        "params": [],
    },
    "get_venue_screening_count_by_date": {
        "title": "16. Venue Screenings by Date",
        "description": "Venue names and number of screenings for a particular date.",
        "params": [
            {"name": "target_date", "type": "date", "label": "Date (YYYY-MM-DD)"}
        ],
    },
    "get_judges_who_havent_evaluated": {
        "title": "17. Judges Who Haven't Evaluated",
        "description": "A list of judges names who has not evaluated a film yet.",
        "params": [],
    },
    "get_films_without_screenings": {
        "title": "18. Films Without Screenings",
        "description": "A list of films names which does not have a screening.",
        "params": [],
    },
    "get_scheduling_conflicts": {
        "title": "19. Overlapping Conflicts",
        "description": "Finds overlapping screenings in the same venue.",
        "params": [],
    },
    "get_top_films_per_category": {
        "title": "20. Top Films Per Category",
        "description": "Ranks films within their category based on average overall rating.",
        "params": [],
    },
}


@ensure_csrf_cookie
def dashboard(request):
    """Renders the main dashboard page."""
    context = {
        "queries": QUERY_CONFIG,
    }
    return render(request, "main/dashboard.html", context)


@require_POST
def execute_query(request):
    """Handles AJAX requests to execute a specific query."""
    try:
        data = json.loads(request.body)
        query_name = data.get("query_name")
        params = data.get("params", {})

        # Ensure the requested function exists in our list
        if query_name not in QUERY_CONFIG:
            return JsonResponse({"error": "Invalid query requested."}, status=400)

        # Get the function from db_operations
        func = getattr(db_operations, query_name, None)
        if not func:
            return JsonResponse({"error": "Function not found."}, status=500)

        # Execute the function with parameters
        # map the params dict to the function arguments.
        result = func(**params) if params else func()

        return JsonResponse({"success": True, "data": result})

    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)
