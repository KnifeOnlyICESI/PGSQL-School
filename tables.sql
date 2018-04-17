/***********************************************************************************************************************
 *
 * This file contains script for create tables in school database
 *
 * Author : Dany Pignoux
 *
***********************************************************************************************************************/

DROP TABLE IF EXISTS average;
DROP TABLE IF EXISTS score;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS grade;

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