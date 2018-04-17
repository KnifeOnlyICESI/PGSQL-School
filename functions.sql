/***********************************************************************************************************************
 *
 * This file contains script for create functions of school database
 *
 * Author : Dany Pignoux
 *
***********************************************************************************************************************/

DROP FUNCTION IF EXISTS get_average(DECIMAL, INTEGER);
DROP FUNCTION IF EXISTS update_average();
DROP FUNCTION IF EXISTS average_already_exists(INTEGER, INTEGER);

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
	where student.grade_id = d_grade_id;

	-- Get the current number of scores
	select COUNT(value) INTO nb_score
	FROM score
	inner JOIN student ON (score.student_id = student.id)
	where student.grade_id = d_grade_id;

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