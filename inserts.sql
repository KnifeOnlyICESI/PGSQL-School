/***********************************************************************************************************************
 *
 * This file contains script for insert data into school database
 *
 * Author : Dany Pignoux
 *
***********************************************************************************************************************/

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