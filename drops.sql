/***********************************************************************************************************************
 *
 * This file contains script for clear empty all database
 *
 * Author : Dany Pignoux
 *
***********************************************************************************************************************/

DROP TRIGGER IF EXISTS trigger_update_average ON score;

DROP FUNCTION IF EXISTS get_average(DECIMAL, INTEGER);
DROP FUNCTION IF EXISTS update_average();
DROP FUNCTION IF EXISTS average_already_exists(INTEGER, INTEGER);

DROP TABLE IF EXISTS average;
DROP TABLE IF EXISTS score;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS grade;