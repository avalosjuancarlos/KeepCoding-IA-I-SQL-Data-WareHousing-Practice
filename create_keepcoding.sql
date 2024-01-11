-- Crear la tabla Countries
CREATE TABLE countries (
	country_id SERIAL PRIMARY KEY,
	country_name VARCHAR(100) NOT NULL,
	country_code VARCHAR(4) NOT NULL
);

-- Crear la tabla Modules
CREATE TABLE modules (
	module_id SERIAL PRIMARY KEY,
	module_name VARCHAR(100) NOT NULL,
	module_description VARCHAR(350) NOT NULL
);

ALTER TABLE modules
	ADD CONSTRAINT unique_module_name UNIQUE (module_name);

-- Crear la tabla Bootcamps
CREATE TABLE bootcamps (
	bootcamp_id SERIAL PRIMARY KEY,
	bootcamp_name VARCHAR(100) NOT NULL,
	bootcamp_description VARCHAR(300) NOT NULL
);

ALTER TABLE bootcamps
	ADD CONSTRAINT unique_bootcamp_name UNIQUE (bootcamp_name);

-- Crear la tabla Students
CREATE TABLE students (
	student_id SERIAL PRIMARY KEY,
	country_id INT NOT NULL,
	student_name VARCHAR(100) NOT NULL,
	student_last_name VARCHAR(100) NOT NULL,
	student_email VARCHAR(250) NOT NULL,
	FOREIGN KEY (country_id) REFERENCES COUNTRIES (country_id)
);

ALTER TABLE students
	ADD CONSTRAINT unique_student_email UNIQUE (student_email);

-- Crear la tabla Teachers
CREATE TABLE teachers (
	teacher_id SERIAL PRIMARY KEY,
	country_id INT NOT NULL,
	teacher_name VARCHAR(100) NOT NULL,
	teacher_last_name VARCHAR(100) NOT NULL,
	teacher_description VARCHAR(350) NOT NULL,
	teacher_email VARCHAR(250) NOT NULL,
	FOREIGN KEY (country_id) REFERENCES COUNTRIES (country_id)
);

ALTER TABLE students
	ADD CONSTRAINT unique_teacher_email UNIQUE (teacher_email);

-- Crear la tabla BOOTCAMP_STUDENTS (relación muchos a muchos entre STUDENT y BOOTCAMP)
CREATE TABLE bootcamp_students (
	bootcamp_student_id SERIAL PRIMARY KEY,
	student_id INT NOT NULL,
	bootcamp_id INT NOT NULL,
	FOREIGN KEY (student_id) REFERENCES STUDENTS (student_id),
	FOREIGN KEY (bootcamp_id) REFERENCES BOOTCAMPS (bootcamp_id),
	UNIQUE (student_id, bootcamp_id)
);

-- Crear la tabla BOOTCAMP_TEACHERS (relación muchos a muchos entre STUDENT y BOOTCAMP)
CREATE TABLE bootcamp_teachers (
	bootcamp_teacher_id SERIAL PRIMARY KEY,
	teacher_id INT NOT NULL,
	bootcamp_id INT NOT NULL,
	FOREIGN KEY (teacher_id) REFERENCES TEACHERS (teacher_id),
	FOREIGN KEY (bootcamp_id) REFERENCES BOOTCAMPS (bootcamp_id),
	UNIQUE (teacher_id, bootcamp_id)
);

-- Crear la tabla BOOTCAMP_MODULES (relación muchos a muchos entre MODULE y BOOTCAMP)
CREATE TABLE bootcamp_modules (
	bootcamp_module_id SERIAL PRIMARY KEY,
	module_id INT NOT NULL,
	bootcamp_id INT NOT NULL,
	FOREIGN KEY (module_id) REFERENCES MODULES (module_id),
	FOREIGN KEY (bootcamp_id) REFERENCES BOOTCAMPS (bootcamp_id),
	UNIQUE (module_id, bootcamp_id)
);

-- Crear la tabla AGENDAS (relación muchos a muchos entre TEACHER y BOOTCAMP_MODULE)
CREATE TABLE agendas (
	agendas_id SERIAL PRIMARY KEY,
	teacher_id INT NOT NULL,
	bootcamp_module_id INT NOT NULL,
	agenda_description VARCHAR(350) NOT NULL,
	agenda_date DATE NOT NULL,
	FOREIGN KEY (teacher_id) REFERENCES TEACHERS (teacher_id),
	FOREIGN KEY (bootcamp_module_id) REFERENCES BOOTCAMP_MODULES (bootcamp_module_id),
	UNIQUE (teacher_id, bootcamp_module_id)
);