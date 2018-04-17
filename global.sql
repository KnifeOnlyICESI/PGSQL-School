/***********************************************************************************************************************
 *
 * This file contains all scripts to create database of school
 *
 * Author : Dany Pignoux
 *
***********************************************************************************************************************/

-- DROPS ###############################################################################################################

DROP TRIGGER IF EXISTS trigger_update_average ON score;

DROP FUNCTION IF EXISTS get_average(DECIMAL, INTEGER);
DROP FUNCTION IF EXISTS update_average();
DROP FUNCTION IF EXISTS average_already_exists(INTEGER, INTEGER);

DROP TABLE IF EXISTS average;
DROP TABLE IF EXISTS score;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS grade;

-- CREATE TABLES #######################################################################################################

CREATE TABLE grade (
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR NOT NULL
);

CREATE TABLE student (
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR NOT NULL,

	grade_id INTEGER NOT NULL REFERENCES grade(id)
);

CREATE TABLE course (
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR NOT NULL
);

CREATE TABLE score (
	id SERIAL PRIMARY KEY NOT NULL,
	value DECIMAL NOT NULL,

	student_id INTEGER NOT NULL REFERENCES student(id),
	course_id INTEGER NOT NULL REFERENCES course(id)
);

CREATE TABLE average (
	value DECIMAL DEFAULT NULL,

	grade_id INTEGER NOT NULL  REFERENCES grade(id),
	course_id INTEGER NOT NULL  REFERENCES course(id),

	PRIMARY KEY (grade_id, course_id)
);

-- CREATE FUNCTIONS ####################################################################################################

--
-- Get average of : pSum / pNb
-- 
-- PARAMS:
-- 	- pSum : The sum to calculate
-- 	- pNb : The number of elements
-- 
-- RETURNS : The average calculated
--
CREATE FUNCTION get_average(IN pSum DECIMAL, IN pNb INTEGER) RETURNS DECIMAL
AS
$BODY$
BEGIN
	RETURN ROUND((pSum / pNb), 2);
END
$BODY$

LANGUAGE PLPGSQL;

--
-- Check if specified average already exists
-- 
-- PARAMS:
-- 	- pGradeId : The associated grade id
-- 	- pCourseId : The associated course id
-- 
-- RETURNS : TRUE if average already exists. FALSE otherwise
--
CREATE FUNCTION average_already_exists(IN pGradeId INTEGER, IN pCourseId INTEGER) RETURNS BOOLEAN
AS
$BODY$
DECLARE
	nb_average INTEGER;
	exists BOOLEAN;
BEGIN
	exists := FALSE;

	select COUNT(*) into nb_average
	from average
	WHERE grade_id = pGradeId
	AND course_id = pCourseId;

	IF nb_average > 0 THEN
		exists := TRUE;
	END IF;

	RETURN exists;
END
$BODY$

LANGUAGE PLPGSQL;

--
-- Update the average (Trigger associated)
-- 
-- RETURNS : NEW (The new element)
--
CREATE FUNCTION update_average() RETURNS TRIGGER
AS
$BODY$
DECLARE 
	d_grade_id INTEGER;
	old_score_sum DECIMAL;
	new_score_sum DECIMAL;
	nb_score INTEGER;
	new_average DECIMAL;
BEGIN
	-- Get the grade of student
	SELECT grade_id INTO d_grade_id
	FROM student
	WHERE id = NEW.student_id;

	-- Get the current sum of scores
	select SUM(value) INTO old_score_sum
	FROM score
	inner JOIN student ON (score.student_id = student.id)
	where student.grade_id = d_grade_id
	AND score.course_id = NEW.course_id;

	-- Get the current number of scores
	select COUNT(value) INTO nb_score
	FROM score
	inner JOIN student ON (score.student_id = student.id)
	where student.grade_id = d_grade_id
	AND score.course_id = NEW.course_id;

	new_score_sum := (old_score_sum + NEW.value);
	new_average := get_average(new_score_sum, nb_score + 1);

	-- If the average already registered, update it
	IF (average_already_exists(d_grade_id, NEW.course_id) = TRUE) THEN
		UPDATE average
		SET value = new_average
		WHERE grade_id = d_grade_id
		AND course_id = NEW.course_id;
	ELSE
		INSERT INTO average (value, grade_id, course_id) VALUES (new_average, d_grade_id, NEW.course_id);
	END IF;

	RETURN NEW;
END
$BODY$

LANGUAGE PLPGSQL;

-- CREATE TRIGGERS #####################################################################################################

CREATE TRIGGER trigger_update_average AFTER INSERT OR UPDATE ON score FOR EACH ROW
EXECUTE PROCEDURE update_average();

-- INSERTS INTO ########################################################################################################

INSERT INTO grade(name) VALUES 
	('6ème'), 
	('5ème'), 
	('4ème'), 
	('3ème'),
	('2nd'),
	('1ère'),
	('Terminale');

INSERT INTO student(name, grade_id) VALUES
	('Dany', 1),
	('Théo', 2),
	('Nathanaël', 3),
	('Mouna', 4),
	('Jean-Christophe', 5),
	('Baptiste', 6),
	('Stannis-Las', 7);

INSERT INTO course(name) VALUES
	('Français'),
	('Anglais'),
	('Histoire'),
	('Mathématiques'),
	('Informatique');
	
INSERT INTO score(value, student_id, course_id) VALUES
	(8.5, 1, 1),
	(10.5, 2, 2),
	(19.5, 3, 3),
	(17.0, 4, 4),
	(14.5, 5, 5),
	(13.5, 6, 1),
	(7.0, 7, 2);