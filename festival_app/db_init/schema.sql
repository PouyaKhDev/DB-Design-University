-- Enable foreign key support
PRAGMA foreign_keys = ON;

-- Drop tables
DROP TABLE IF EXISTS Award;
DROP TABLE IF EXISTS Evaluation;
DROP TABLE IF EXISTS Screening;
DROP TABLE IF EXISTS FilmJudge;
DROP TABLE IF EXISTS Judge;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS FilmPerson;
DROP TABLE IF EXISTS Film;
DROP TABLE IF EXISTS Person;
DROP TABLE IF EXISTS Venue;
DROP TABLE IF EXISTS FestivalCategory;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS Festival;

-- TABLE DEFINITIONS

CREATE TABLE Festival (
    festival_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title VARCHAR(200) NOT NULL,
    date DATE NOT NULL,
    location VARCHAR(200)
);

CREATE TABLE Category (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE FestivalCategory (
    festival_category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    festival_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    FOREIGN KEY (festival_id) REFERENCES Festival(festival_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE CASCADE,
    UNIQUE (festival_id, category_id)
);

CREATE TABLE Venue (
    venue_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(200) NOT NULL,
    address VARCHAR(300),
    capacity INTEGER,
    festival_id INTEGER,
    FOREIGN KEY (festival_id) REFERENCES Festival(festival_id) ON DELETE SET NULL,
    CHECK (capacity > 0)
);

CREATE TABLE Person (
    person_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(100),
    biography TEXT,
    UNIQUE (first_name, last_name, birth_date)
);

CREATE TABLE Film (
    film_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title VARCHAR(300) NOT NULL,
    release_year INTEGER,
    duration_minutes INTEGER,
    country VARCHAR(100),
    category_id INTEGER NOT NULL,
    festival_id INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE RESTRICT,
    FOREIGN KEY (festival_id) REFERENCES Festival(festival_id) ON DELETE CASCADE,
    CHECK (release_year >= 1800 AND release_year <= 2100),
    CHECK (duration_minutes > 0)
);

CREATE TABLE FilmPerson (
    film_person_id INTEGER PRIMARY KEY AUTOINCREMENT,
    film_id INTEGER NOT NULL,
    person_id INTEGER NOT NULL,
    role_type VARCHAR(100) NOT NULL,
    FOREIGN KEY (film_id) REFERENCES Film(film_id) ON DELETE CASCADE,
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE,
    UNIQUE (film_id, person_id, role_type),
    CHECK (role_type IN ('director', 'actor'))
);

CREATE TABLE Staff (
    staff_id INTEGER PRIMARY KEY AUTOINCREMENT,
    person_id INTEGER NOT NULL,
    festival_id INTEGER NOT NULL,
    position VARCHAR(100) NOT NULL,
    department VARCHAR(100),
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE,
    FOREIGN KEY (festival_id) REFERENCES Festival(festival_id) ON DELETE CASCADE,
    UNIQUE (person_id, festival_id, position)
);

CREATE TABLE Judge (
    judge_id INTEGER PRIMARY KEY AUTOINCREMENT,
    person_id INTEGER NOT NULL,
    festival_id INTEGER NOT NULL,
    expertise VARCHAR(100),
    certification_level VARCHAR(50),
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE,
    FOREIGN KEY (festival_id) REFERENCES Festival(festival_id) ON DELETE CASCADE,
    UNIQUE (person_id, festival_id),
    CHECK (certification_level IN ('international', 'national')),
    CHECK (expertise IN ('feature', 'documentary', 'animation', 'short'))
);

CREATE TABLE FilmJudge (
    film_judge_id INTEGER PRIMARY KEY AUTOINCREMENT,
    film_id INTEGER NOT NULL,
    judge_id INTEGER NOT NULL,
    FOREIGN KEY (film_id) REFERENCES Film(film_id) ON DELETE CASCADE,
    FOREIGN KEY (judge_id) REFERENCES Judge(judge_id) ON DELETE CASCADE,
    UNIQUE (film_id, judge_id)
);

CREATE TABLE Screening (
    screening_id INTEGER PRIMARY KEY AUTOINCREMENT,
    film_id INTEGER NOT NULL,
    venue_id INTEGER NOT NULL,
    organizer_id INTEGER NOT NULL,
    screening_datetime DATETIME NOT NULL,
    duration_minutes INTEGER,
    FOREIGN KEY (film_id) REFERENCES Film(film_id) ON DELETE CASCADE,
    FOREIGN KEY (venue_id) REFERENCES Venue(venue_id) ON DELETE CASCADE,
    FOREIGN KEY (organizer_id) REFERENCES Staff(staff_id) ON DELETE CASCADE
);

CREATE TABLE Evaluation (
    evaluation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    film_id INTEGER NOT NULL,
    judge_id INTEGER NOT NULL,
    criterion VARCHAR(100) NOT NULL,
    score DECIMAL(3, 1) NOT NULL,
    comments TEXT,
    FOREIGN KEY (film_id) REFERENCES Film(film_id) ON DELETE CASCADE,
    FOREIGN KEY (judge_id) REFERENCES Judge(judge_id) ON DELETE CASCADE,
    UNIQUE (film_id, judge_id, criterion),
    CHECK (score >= 0 AND score <= 10),
    CHECK (criterion IN ('story', 'acting', 'cinematography', 'direction', 'sound', 'editing', 'overall'))
);

CREATE TABLE Award (
    award_id INTEGER PRIMARY KEY AUTOINCREMENT,
    film_id INTEGER NOT NULL,
    festival_id INTEGER NOT NULL,
    award_name VARCHAR(200) NOT NULL,
    award_category VARCHAR(100),
    award_date DATE,
    prize_amount DECIMAL(10, 2) DEFAULT 0.00,
    description TEXT,
    FOREIGN KEY (film_id) REFERENCES Film(film_id) ON DELETE CASCADE,
    FOREIGN KEY (festival_id) REFERENCES Festival(festival_id) ON DELETE CASCADE
);

-- PERFORMANCE OPTIMIZATION (INDEXES)
CREATE INDEX idx_festivalcategory_festival ON FestivalCategory(festival_id);
CREATE INDEX idx_festivalcategory_category ON FestivalCategory(category_id);
CREATE INDEX idx_venue_festival ON Venue(festival_id);
CREATE INDEX idx_film_category ON Film(category_id);
CREATE INDEX idx_film_festival ON Film(festival_id);
CREATE INDEX idx_film_release_year ON Film(release_year);
CREATE INDEX idx_filmperson_film ON FilmPerson(film_id);
CREATE INDEX idx_filmperson_person ON FilmPerson(person_id);
CREATE INDEX idx_filmperson_role ON FilmPerson(role_type);
CREATE INDEX idx_staff_person ON Staff(person_id);
CREATE INDEX idx_staff_festival ON Staff(festival_id);
CREATE INDEX idx_judge_person ON Judge(person_id);
CREATE INDEX idx_judge_festival ON Judge(festival_id);
CREATE INDEX idx_judge_expertise ON Judge(expertise);
CREATE INDEX idx_filmjudge_film ON FilmJudge(film_id);
CREATE INDEX idx_filmjudge_judge ON FilmJudge(judge_id);
CREATE INDEX idx_screening_film ON Screening(film_id);
CREATE INDEX idx_screening_venue ON Screening(venue_id);
CREATE INDEX idx_screening_organizer ON Screening(organizer_id);
CREATE INDEX idx_screening_datetime ON Screening(screening_datetime);
CREATE INDEX idx_evaluation_film ON Evaluation(film_id);
CREATE INDEX idx_evaluation_judge ON Evaluation(judge_id);
CREATE INDEX idx_evaluation_criterion ON Evaluation(criterion);
CREATE INDEX idx_award_film ON Award(film_id);
CREATE INDEX idx_award_festival ON Award(festival_id);

-- SAMPLE DATA

-- 5 Categories
INSERT INTO Category (name, description) VALUES
('Feature', 'Full-length feature films'),
('Documentary', 'Non-fiction documentary films'),
('Animation', 'Animated films'),
('Short', 'Short films under 40 minutes'),
('Experimental', 'Avant-garde experimental films');

-- 2 Festivals
INSERT INTO Festival (title, date, location) VALUES
('Tehran International Film Festival', '2026-04-15', 'Tehran, Iran'),
('Fajr Film Festival', '2026-02-01', 'Tehran, Iran');

-- Festival Categories Mapping
INSERT INTO FestivalCategory (festival_id, category_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
(2, 1), (2, 2), (2, 3), (2, 4);

-- Venues
INSERT INTO Venue (name, address, capacity, festival_id) VALUES
('Main Hall', 'Milad Tower', 500, 1), ('Hall A', 'Vahdat Hall', 300, 1),
('Cinema City', 'Kourosh Mall', 200, 2), ('Outdoor Screen', 'Park Daneshgah', 1000, 2);

-- 70 Persons
-- IDs 1-40: Directors/Actors | IDs 41-46: Judges | IDs 47-70: Staff Organizers
INSERT INTO Person (first_name, last_name, birth_date, nationality, biography) VALUES
('Ali', 'Rezaei', '1975-03-15', 'Iranian', 'Director'), ('Maryam', 'Hosseini', '1980-07-22', 'Iranian', 'Producer'),
('Reza', 'Moradi', '1968-11-30', 'Iranian', 'Cinematographer'), ('Sarah', 'Johnson', '1985-05-10', 'American', 'Critic'),
('Mohammad', 'Ahmadi', '1972-09-18', 'Iranian', 'Organizer'), ('Elena', 'Rodriguez', '1978-12-05', 'Spanish', 'Director'),
('Hassan', 'Fathi', '1982-04-14', 'Iranian', 'Writer'), ('Nina', 'Petrova', '1970-08-20', 'Russian', 'Animator'),
('David', 'Chen', '1988-01-25', 'Canadian', 'Director'), ('Leila', 'Karimi', '1990-06-30', 'Iranian', 'Director'),
('Amir', 'Jadidi', '1985-11-12', 'Iranian', 'Actor'), ('Taraneh', 'Alidoosti', '1984-05-12', 'Iranian', 'Actress'),
('Shahab', 'Hosseini', '1974-02-08', 'Iranian', 'Actor'), ('Pegah', 'Ferdowsi', '1983-03-15', 'Iranian', 'Actress'),
('Navid', 'Mohammadzadeh', '1981-09-27', 'Iranian', 'Actor'), ('Leila', 'Hatami', '1972-10-09', 'Iranian', 'Actress'),
('Babak', 'Karimi', '1966-07-15', 'Iranian', 'Actor'), ('Sareh', 'Bayat', '1983-03-01', 'Iranian', 'Actress'),
('Payman', 'Maadi', '1970-07-01', 'Iranian', 'Actor'), ('Hediyeh', 'Tehrani', '1972-08-03', 'Iranian', 'Actress'),
('Kourosh', 'Narimani', '1975-05-20', 'Iranian', 'Editor'), ('Mahmoud', 'Kosary', '1960-03-10', 'Iranian', 'Producer'),
('Roya', 'Nonahali', '1978-09-15', 'Iranian', 'Designer'), ('Hamid', 'Salahmand', '1980-11-22', 'Iranian', 'Manager'),
('Zahra', 'AmirEbrahimi', '1981-07-01', 'Iranian', 'Actress'), ('Mehran', 'Modiri', '1965-04-07', 'Iranian', 'Director'),
('Mani', 'Haghighi', '1969-04-12', 'Iranian', 'Director'), ('Asghar', 'Farhadi', '1972-05-07', 'Iranian', 'Director'),
('Majid', 'Majidi', '1959-04-17', 'Iranian', 'Director'), ('Abbas', 'Kiarostami', '1940-06-22', 'Iranian', 'Director'),
('Ali', 'Mosaffa', '1967-12-02', 'Iranian', 'Actor'), ('Fatemeh', 'MotamedArya', '1961-10-23', 'Iranian', 'Actress'),
('Mohammad', 'Forutan', '1967-02-15', 'Iranian', 'Actor'), ('Amin', 'Hayaei', '1970-07-24', 'Iranian', 'Actor'),
('Javad', 'Ezzati', '1973-06-26', 'Iranian', 'Actor'), ('Mohsen', 'Tanabandeh', '1975-05-15', 'Iranian', 'Actor'),
('Hamed', 'Behdad', '1973-05-02', 'Iranian', 'Actor'), ('Baran', 'Kosari', '1983-11-22', 'Iranian', 'Actress'),
('Taha', 'Hosseini', '1995-08-10', 'Iranian', 'Actor'), ('Sara', 'Bahrami', '1984-02-14', 'Iranian', 'Actress'),
-- Judges (41-46)
('Ahmad', 'Nazari', '1970-01-15', 'Iranian', 'Film critic'), ('Fariba', 'Rahimi', '1975-06-20', 'Iranian', 'Professor'),
('Kamran', 'Delan', '1968-09-10', 'Iranian', 'Director'), ('Susan', 'Taslimi', '1982-03-25', 'Iranian', 'Critic'),
('Behrouz', 'Vossoughi', '1965-11-30', 'Iranian', 'Expert'), ('Niki', 'Karimi', '1971-11-10', 'Iranian', 'Director'),
-- Staff Organizers (47-70)
('Reza', 'Mirkarimi', '1967-01-01', 'Iranian', 'Organizer'), ('Maryam', 'Shahriar', '1973-04-18', 'Iranian', 'Coordinator'),
('Hossein', 'Shahabi', '1969-08-05', 'Iranian', 'Tech Manager'), ('Shirin', 'Neshat', '1976-12-12', 'Iranian', 'PR Manager'),
('Jafar', 'Panahi', '1974-07-20', 'Iranian', 'Volunteer Coord'), ('Rakhshan', 'BaniEtemad', '1970-05-15', 'Iranian', 'Ticketing'),
('Bahman', 'Ghobadi', '1968-02-28', 'Iranian', 'Venue Manager'), ('Tahmineh', 'Milani', '1972-09-08', 'Iranian', 'Security'),
('Samira', 'Makhmalbaf', '1975-11-22', 'Iranian', 'Catering'), ('Abbas', 'Rafei', '1971-06-14', 'Iranian', 'Guest Relations'),
('Parviz', 'Shahbazi', '1969-03-30', 'Iranian', 'Organizer'), ('Marzieh', 'Meshkini', '1973-08-17', 'Iranian', 'Coordinator'),
('Rasoul', 'Mollagholipour', '1967-10-25', 'Iranian', 'Tech Manager'), ('Pouran', 'Derakhshandeh', '1970-04-02', 'Iranian', 'PR Manager'),
('Kambuzia', 'Partovi', '1974-12-19', 'Iranian', 'Volunteer Coord'), ('Mahmoud', 'Kalari', '1968-07-11', 'Iranian', 'Ticketing'),
('Narges', 'Abyar', '1972-01-28', 'Iranian', 'Venue Manager'), ('Maziar', 'Bahari', '1971-05-06', 'Iranian', 'Security'),
('Sepideh', 'Farsi', '1973-09-13', 'Iranian', 'Catering'), ('Hassan', 'Yektapanah', '1969-11-01', 'Iranian', 'Guest Relations'),
('Roya', 'Sadat', '1975-02-24', 'Iranian', 'Logistics'), ('Sahar', 'Sotoudeh', '1970-08-16', 'Iranian', 'Marketing'),
('Amir', 'Naderi', '1968-06-09', 'Iranian', 'Logistics'), ('Shahla', 'Lahiji', '1972-10-31', 'Iranian', 'Marketing');

-- 15 Films
INSERT INTO Film (title, release_year, duration_minutes, country, category_id, festival_id) VALUES
('The Last Journey', 2025, 105, 'Iran', 1, 1), ('Laughing Days', 2026, 95, 'Iran', 1, 1),
('Truth Unveiled', 2025, 88, 'Iran', 2, 1), ('City of Dreams', 2026, 120, 'Iran', 1, 1),
('Shadows', 2025, 30, 'Iran', 4, 1), ('The Silent River', 2025, 110, 'Iran', 1, 2),
('Midnight Laughs', 2026, 90, 'Iran', 1, 2), ('Voices of Earth', 2025, 95, 'Iran', 2, 2),
('Escape Route', 2026, 115, 'Iran', 1, 2), ('Pixelated World', 2026, 85, 'Iran', 3, 2),
('Broken Mirrors', 2025, 100, 'Iran', 1, 1), ('The Jester', 2026, 98, 'Iran', 1, 1),
('Behind the Lens', 2025, 75, 'Iran', 2, 2), ('Red Line', 2026, 105, 'Iran', 1, 1),
('Little Painter', 2026, 80, 'Iran', 3, 1);

-- FilmPerson (Using Persons 1-40)
INSERT INTO FilmPerson (film_id, person_id, role_type) VALUES
(1, 1, 'director'), (1, 11, 'actor'), (1, 12, 'actor'),
(2, 26, 'director'), (2, 35, 'actor'), (2, 34, 'actor'),
(3, 3, 'director'), (3, 2, 'actor'),
(4, 9, 'director'), (4, 37, 'actor'), (4, 38, 'actor'),
(5, 10, 'director'), (5, 40, 'actor'),
(6, 28, 'director'), (6, 13, 'actor'), (6, 14, 'actor'),
(7, 26, 'director'), (7, 25, 'actor'), (7, 24, 'actor'),
(8, 6, 'director'), (8, 5, 'actor'),
(9, 9, 'director'), (9, 15, 'actor'), (9, 16, 'actor'),
(10, 8, 'director'), (10, 7, 'actor'),
(11, 28, 'director'), (11, 17, 'actor'), (11, 18, 'actor'),
(12, 26, 'director'), (12, 23, 'actor'),
(13, 3, 'director'), (13, 22, 'actor'),
(14, 9, 'director'), (14, 19, 'actor'), (14, 20, 'actor'),
(15, 8, 'director'), (15, 7, 'actor'),
(1, 21, 'actor'), (1, 22, 'actor'), (2, 36, 'actor'), (2, 33, 'actor'),
(4, 27, 'actor'), (4, 29, 'actor'), (6, 30, 'actor'), (6, 31, 'actor'),
(7, 32, 'actor'), (9, 21, 'actor'), (11, 31, 'actor'), (11, 32, 'actor'),
(12, 33, 'actor'), (14, 34, 'actor');

-- Staff (24 Organizers using Persons 47-70)
INSERT INTO Staff (person_id, festival_id, position, department) VALUES
(47, 1, 'Festival Director', 'Admin'), (48, 1, 'Event Coordinator', 'Ops'),
(49, 1, 'Technical Manager', 'IT'), (50, 1, 'PR Manager', 'Media'),
(51, 1, 'Volunteer Coord', 'HR'), (52, 1, 'Ticketing Manager', 'Sales'),
(53, 1, 'Venue Manager', 'Ops'), (54, 1, 'Security Chief', 'Security'),
(55, 1, 'Catering Manager', 'Services'), (56, 1, 'Guest Relations', 'Hospitality'),
(57, 2, 'Festival Director', 'Admin'), (58, 2, 'Event Coordinator', 'Ops'),
(59, 2, 'Technical Manager', 'IT'), (60, 2, 'PR Manager', 'Media'),
(61, 2, 'Volunteer Coord', 'HR'), (62, 2, 'Ticketing Manager', 'Sales'),
(63, 2, 'Venue Manager', 'Ops'), (64, 2, 'Security Chief', 'Security'),
(65, 2, 'Catering Manager', 'Services'), (66, 2, 'Guest Relations', 'Hospitality'),
(67, 1, 'Logistics Officer', 'Ops'), (68, 1, 'Marketing Specialist', 'Media'),
(69, 2, 'Logistics Officer', 'Ops'), (70, 2, 'Marketing Specialist', 'Media');

-- 6 Judges (using Persons 41-46)
INSERT INTO Judge (person_id, festival_id, expertise, certification_level) VALUES
(41, 1, 'feature', 'international'), (42, 1, 'documentary', 'national'),
(43, 1, 'animation', 'international'), (44, 1, 'short', 'international'),
(45, 2, 'feature', 'national'), (46, 2, 'documentary', 'international');

-- FilmJudge Assignments
INSERT INTO FilmJudge (film_id, judge_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (2, 1), (2, 2), (2, 3), (3, 2), (3, 4),
(4, 1), (4, 3), (4, 4), (5, 3), (5, 4), (11, 1), (11, 2), (11, 3),
(12, 1), (12, 4), (14, 1), (14, 3), (14, 4), (15, 2), (15, 3),
(6, 5), (6, 6), (7, 5), (7, 6), (8, 5), (8, 6), (9, 5), (9, 6),
(10, 5), (10, 6), (13, 5), (13, 6);

-- Screenings
INSERT INTO Screening (film_id, venue_id, organizer_id, screening_datetime, duration_minutes) VALUES
(1, 1, 1, '2026-04-16 18:00:00', 105), (2, 2, 2, '2026-04-17 20:00:00', 95),
(6, 3, 11, '2026-02-02 18:00:00', 110), (10, 4, 12, '2026-02-05 19:00:00', 85);

-- 35 Evaluations (Strictly using judge_id 1-6)
INSERT INTO Evaluation (film_id, judge_id, criterion, score, comments) VALUES
(1, 1, 'story', 9.0, 'Compelling'), (1, 1, 'direction', 8.5, 'Excellent'),
(1, 2, 'acting', 9.5, 'Outstanding'), (2, 1, 'story', 7.5, 'Light-hearted'),
(2, 3, 'cinematography', 8.0, 'Beautiful'), (3, 2, 'overall', 9.0, 'Powerful'),
(4, 4, 'direction', 8.5, 'Great action'), (4, 1, 'story', 7.0, 'Well executed'),
(5, 3, 'cinematography', 9.0, 'Stunning'), (11, 1, 'acting', 8.5, 'Nuanced'),
(11, 2, 'story', 8.0, 'Thought-provoking'), (12, 4, 'direction', 7.5, 'Good timing'),
(14, 1, 'story', 8.0, 'Thrilling'), (14, 3, 'acting', 7.5, 'Solid'),
(15, 2, 'overall', 8.5, 'Charming'), (6, 5, 'story', 9.5, 'Masterpiece'),
(6, 5, 'direction', 9.0, 'Flawless'), (6, 6, 'acting', 9.5, 'Authentic'),
(7, 5, 'story', 7.0, 'Entertaining'), (7, 6, 'cinematography', 7.5, 'Good lighting'),
(8, 6, 'overall', 9.0, 'Eye-opening'), (9, 5, 'direction', 8.0, 'Great stunts'),
(9, 6, 'story', 6.5, 'Standard plot'), (10, 5, 'overall', 8.5, 'Delightful'),
(13, 6, 'cinematography', 9.0, 'Breathtaking'), (13, 5, 'story', 8.0, 'Fascinating'),
(1, 4, 'cinematography', 8.0, 'Great lighting'), (2, 2, 'acting', 8.5, 'Very funny'),
(4, 3, 'sound', 9.0, 'Excellent sound'), (6, 6, 'direction', 9.5, 'Masterful'),
(8, 5, 'story', 8.5, 'Well researched'), (9, 5, 'sound', 8.5, 'Immersive'),
(11, 3, 'direction', 8.5, 'Atmospheric'), (12, 1, 'acting', 8.0, 'Great comedy'),
(14, 4, 'sound', 8.5, 'Great score');

-- Awards
INSERT INTO Award (film_id, festival_id, award_name, award_category, award_date, prize_amount, description) VALUES
(1, 1, 'Best Film', 'Feature', '2026-04-22', 100000000.00, 'Top prize'),
(6, 2, 'Best Director', 'Feature', '2026-02-11', 50000000.00, 'Outstanding direction'),
(10, 2, 'Best Animation', 'Animation', '2026-02-11', 30000000.00, 'Creative visuals');




-- ADDITIONAL SAMPLE DATA SO THAT ALL QUERIES HAVE RECORDS

-- 1. Add 3 Extra Persons (IDs 71, 72, 73)
INSERT INTO Person (first_name, last_name, birth_date, nationality, biography) VALUES
('Kambiz', 'EmptyRole', '1980-01-01', 'Iranian', 'Judge with no evaluations yet'),
('Sina', 'ExtraActor', '1990-05-15', 'Iranian', 'Actor for multi-film query'),
('Nima', 'CoDirector', '1975-08-20', 'Iranian', 'Co-director for multi-director query');

-- 2. Add Judge 7 (Person 71) who has NO evaluations
INSERT INTO Judge (person_id, festival_id, expertise, certification_level) VALUES
(71, 1, 'feature', 'national');

-- 3. Make Person 41 BOTH a Judge AND Staff
INSERT INTO Staff (person_id, festival_id, position, department) VALUES
(41, 1, 'Jury Coordinator', 'Administration');

-- 4. Add Co-Director to Film 1
INSERT INTO FilmPerson (film_id, person_id, role_type) VALUES
(1, 73, 'director');

-- 5. Make Person 11 act in 2 MORE films
INSERT INTO FilmPerson (film_id, person_id, role_type) VALUES
(4, 11, 'actor'),
(6, 11, 'actor');

-- 6. Add Screenings on the SAME DAY
INSERT INTO Screening (film_id, venue_id, organizer_id, screening_datetime, duration_minutes) VALUES
(3, 1, 1, '2026-04-16 14:00:00', 88),
(4, 2, 2, '2026-04-16 16:00:00', 120),
(5, 1, 1, '2026-04-16 18:00:00', 30);

-- 7. Add a FUTURE Screening
INSERT INTO Screening (film_id, venue_id, organizer_id, screening_datetime, duration_minutes) VALUES
(1, 1, 1, '2027-05-01 20:00:00', 105);

-- 8. Create a SCHEDULING CONFLICT
INSERT INTO Screening (film_id, venue_id, organizer_id, screening_datetime, duration_minutes) VALUES
(5, 1, 1, '2026-04-16 14:30:00', 30);

-- 9. Add overal more overall ratings
INSERT INTO Evaluation (film_id, judge_id, criterion, score, comments) VALUES
(1, 3, 'overall', 8.5, 'Great film'),
(2, 4, 'overall', 7.5, 'Good pacing'),
(4, 2, 'overall', 7.0, 'Action packed'),
(5, 1, 'overall', 8.0, 'Great short'),
(7, 5, 'overall', 6.5, 'Repetitive'),
(9, 6, 'overall', 7.0, 'Standard'),
(11, 4, 'overall', 8.0, 'Deep'),
(12, 2, 'overall', 7.5, 'Funny'),
(13, 6, 'overall', 8.5, 'Beautiful'),
(14, 4, 'overall', 7.5, 'Exciting');

-- 10. Give an AWARD to an UNRATED film
INSERT INTO Award (film_id, festival_id, award_name, award_category, award_date, prize_amount, description) VALUES
(15, 1, 'Jury Special Mention', 'Experimental', '2026-04-22', 5000000.00, 'Awarded despite lack of formal evaluation');


-- Add 2 new films
INSERT INTO Film (title, release_year, duration_minutes, country, category_id, festival_id) VALUES
('The Unseen Path', 2026, 110, 'Iran', 1, 1),
('Silent Echoes', 2026, 95, 'Iran', 2, 1);

-- Add Cast for them
INSERT INTO FilmPerson (film_id, person_id, role_type) VALUES
(16, 27, 'director'), (16, 31, 'actor'),
(17, 29, 'director'), (17, 32, 'actor');

-- Add Screenings for them
INSERT INTO Screening (film_id, venue_id, organizer_id, screening_datetime, duration_minutes) VALUES
(16, 1, 1, '2026-04-18 18:00:00', 110),
(17, 2, 2, '2026-04-19 20:00:00', 95);