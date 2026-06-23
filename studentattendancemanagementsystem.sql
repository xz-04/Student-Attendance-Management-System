-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 23, 2026 at 06:56 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `studentattendancemanagementsystem`
--

-- --------------------------------------------------------

--
-- Table structure for table `absenceleave`
--

CREATE TABLE `absenceleave` (
  `leaveId` varchar(100) NOT NULL,
  `matricNo` varchar(20) NOT NULL,
  `courseCode` varchar(20) NOT NULL,
  `date` date NOT NULL,
  `category` varchar(30) NOT NULL,
  `reason` text DEFAULT NULL,
  `evidencePath` varchar(255) DEFAULT NULL,
  `approvalStatus` varchar(20) DEFAULT 'Pending',
  `rejectReason` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `attendancerecord`
--

CREATE TABLE `attendancerecord` (
  `recordId` varchar(100) NOT NULL,
  `sessionId` varchar(100) NOT NULL,
  `matricNo` varchar(20) NOT NULL,
  `checkinTime` timestamp NOT NULL DEFAULT current_timestamp(),
  `ipAddress` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `attendancesession`
--

CREATE TABLE `attendancesession` (
  `sessionId` varchar(100) NOT NULL,
  `courseCode` varchar(20) NOT NULL,
  `matricNo` varchar(20) NOT NULL,
  `date` date NOT NULL,
  `startTime` time NOT NULL,
  `endTime` time NOT NULL,
  `venue` varchar(100) DEFAULT NULL,
  `qrToken` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `course`
--

CREATE TABLE `course` (
  `facultyName` varchar(10) NOT NULL,
  `courseCode` varchar(20) NOT NULL,
  `courseName` varchar(100) NOT NULL,
  `yearOfStudy` int(1) DEFAULT NULL,
  `semesterTarget` int(1) DEFAULT NULL,
  `courseStatus` varchar(20) NOT NULL DEFAULT 'Core'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `course`
--

INSERT INTO `course` (`facultyName`, `courseCode`, `courseName`, `yearOfStudy`, `semesterTarget`, `courseStatus`) VALUES
('FSKM', 'CSE3023', 'Web-Based Application Development', 2, 2, 'Core'),
('FSKM', 'CSE3203', 'Software Requirement Engineering', 1, 2, 'Core'),
('FSKM', 'CSE3403', 'Software Project Management', 3, 1, 'Core'),
('FSKM', 'CSE3413', 'Software Testing', 2, 2, 'Core'),
('FSKM', 'CSE3423', 'Software Quality Assurance', 3, 1, 'Core'),
('FSKM', 'CSE3433', 'Software Architecture', 2, 2, 'Core'),
('FSKM', 'CSE3443', 'Software Maintenance and Evolution', 3, 2, 'Core'),
('FSKM', 'CSE3453', 'Ethics and Professionalism Practices', 3, 2, 'Core'),
('FSKM', 'CSE3953', 'Application System Development Project', 2, 2, 'Core'),
('FSKM', 'CSF3003', 'Discrete Structure', 1, 1, 'Core'),
('FSKM', 'CSF3013', 'Data Structure and Algorithm', 2, 1, 'Core'),
('FSKM', 'CSF3023', 'System Thinking and Logic', 1, 1, 'Core'),
('FSKM', 'CSF3034', 'Programming', 1, 1, 'Core'),
('FSKM', 'CSF3043', 'Object-Oriented Programming', 1, 2, 'Core'),
('FSKM', 'CSF3113', 'System Analysis and Design', 2, 1, 'Core'),
('FSKM', 'CSF3123', 'Database', 2, 1, 'Core'),
('FSKM', 'CSF3133', 'Web-Based Interface Design', 2, 1, 'Core'),
('FSKM', 'CSF3143', 'Basics of Software Engineering', 1, 1, 'Core'),
('FSKM', 'CSF3213', 'Operating Systems', 1, 2, 'Core'),
('FSKM', 'CSF3223', 'Networking', 2, 2, 'Core'),
('FSKM', 'CSF3233', 'Cyber Security', 3, 2, 'Core'),
('FSKM', 'CSF3243', 'Computer Organisation and Architecture', 1, 1, 'Core'),
('FSKM', 'CSF3253', 'Intelligent System', 3, 1, 'Core'),
('FSKM', 'CSF4984', 'Final Year Project I', 3, 1, 'Core'),
('FSKM', 'CSF4994', 'Final Year Project II', 3, 2, 'Core'),
('FSKM', 'CSM3313', 'IoT Computing', 3, 1, 'Core'),
('PPAL', 'JAP1001', 'Japanese I', NULL, NULL, 'Elective'),
('PPAL', 'JAP2001', 'Japanese II', NULL, NULL, 'Elective'),
('PPAL', 'KOR1001', 'Korean I', NULL, NULL, 'Elective'),
('PPAL', 'KOR2001', 'Korean II', NULL, NULL, 'Elective'),
('FSKM', 'MTK3053', 'Introduction to Statistics', 1, 2, 'Core');

--
-- Triggers `course`
--
DELIMITER $$
CREATE TRIGGER `auto_assign_new_course_to_students` AFTER INSERT ON `course` FOR EACH ROW BEGIN
    IF NEW.courseStatus = 'Core' THEN
        INSERT INTO studentcourse (matricNo, courseCode)
        SELECT s.matricNo, NEW.courseCode
        FROM v_student_current_status s
        WHERE (
            (s.currentLevel LIKE CONCAT('%', NEW.yearOfStudy, 'nd Year (Sem ', NEW.semesterTarget, ')%')) OR
            (s.currentLevel LIKE CONCAT('%', NEW.yearOfStudy, 'st Year (Sem ', NEW.semesterTarget, ')%')) OR
            (s.currentLevel LIKE CONCAT('%', NEW.yearOfStudy, 'rd Year (Sem ', NEW.semesterTarget, ')%')) OR
            (s.currentLevel LIKE CONCAT('%', NEW.yearOfStudy, 'th Year+ (Sem ', NEW.semesterTarget, ')%'))
        ) 
        OR 
        (
            NEW.yearOfStudy = 1 
            AND NEW.semesterTarget = 1 
            AND (s.currentLevel LIKE '%Sem 1 Induction%' OR s.currentLevel LIKE '%Upcoming Sem 1%')
        );
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `faculty`
--

CREATE TABLE `faculty` (
  `facultyName` varchar(10) NOT NULL,
  `facultyFullname` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `faculty`
--

INSERT INTO `faculty` (`facultyName`, `facultyFullname`) VALUES
('FPEPS', 'FAKULTI PERNIAGAAN, EKONOMI DAN PEMBANGUNAN SOSIAL'),
('FPM', 'FAKULTI PENGAJIAN MARITIM'),
('FPSA', 'FAKULTI SAINS PERIKANAN DAN AKUAKULTUR'),
('FSKM', 'FAKULTI SAINS KOMPUTER DAN MATEMATIK'),
('FSMA', 'FAKULTI SAINS MAKANAN DAN AGROTEKNOLOGI'),
('FSSM', 'FAKULTI SAINS DAN SEKITARAN MARIN'),
('FTKK', 'FAKULTI TEKNOLOGI KEJURUTERAAN KELAUTAN'),
('PASTEM', 'PUSAT ASASI STEM'),
('PPAL', 'PUSAT PENDIDIKAN ASAS DAN LANJUTAN'),
('PPPA', 'PUSAT PEMBANGUNAN DAN PENGURUSAN AKADEMIK');

-- --------------------------------------------------------

--
-- Table structure for table `lecturer`
--

CREATE TABLE `lecturer` (
  `matricNo` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `lecturer`
--

INSERT INTO `lecturer` (`matricNo`) VALUES
('L001'),
('L002'),
('L003'),
('L004'),
('L005'),
('L006'),
('L007'),
('L008'),
('L009'),
('L010');

-- --------------------------------------------------------

--
-- Table structure for table `lecturercourse`
--

CREATE TABLE `lecturercourse` (
  `matricNo` varchar(20) NOT NULL,
  `courseCode` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `programme`
--

CREATE TABLE `programme` (
  `programmeId` varchar(10) NOT NULL,
  `programmeName` varchar(100) NOT NULL,
  `facultyName` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `programme`
--

INSERT INTO `programme` (`programmeId`, `programmeName`, `facultyName`) VALUES
('CS-IM', 'COMPUTER SCIENCE (MARITIME INFORMATICS)', 'FSKM'),
('CS-MC', 'COMPUTER SCIENCE (MOBILE COMPUTING)', 'FSKM'),
('CS-SE', 'COMPUTER SCIENCE (SOFTWARE ENGINEERING)', 'FSKM');

-- --------------------------------------------------------

--
-- Table structure for table `student`
--

CREATE TABLE `student` (
  `matricNo` varchar(20) NOT NULL,
  `programmeId` varchar(10) NOT NULL,
  `intakeDate` date NOT NULL,
  `session` varchar(20) GENERATED ALWAYS AS (case when month(`intakeDate`) >= 8 then concat(year(`intakeDate`),'/',year(`intakeDate`) + 1) else concat(year(`intakeDate`) - 1,'/',year(`intakeDate`)) end) STORED,
  `semester` varchar(20) GENERATED ALWAYS AS (case when month(`intakeDate`) >= 8 or month(`intakeDate`) <= 2 then 'Semester 1' else 'Semester 2' end) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student`
--

INSERT INTO `student` (`matricNo`, `programmeId`, `intakeDate`) VALUES
('S001', 'CS-SE', '2025-09-17'),
('S002', 'CS-SE', '2025-09-17'),
('S003', 'CS-SE', '2025-09-17'),
('S004', 'CS-SE', '2025-09-17'),
('S005', 'CS-IM', '2026-02-15'),
('S006', 'CS-SE', '2025-09-17'),
('S007', 'CS-SE', '2025-09-17'),
('S008', 'CS-MC', '2025-09-17'),
('S009', 'CS-MC', '2025-09-17'),
('S010', 'CS-IM', '2025-09-17'),
('S011', 'CS-IM', '2025-09-17'),
('S012', 'CS-SE', '2026-02-15'),
('S013', 'CS-SE', '2026-02-15'),
('S014', 'CS-MC', '2026-02-15'),
('S015', 'CS-MC', '2026-02-15');

--
-- Triggers `student`
--
DELIMITER $$
CREATE TRIGGER `auto_assign_student_courses` AFTER INSERT ON `student` FOR EACH ROW BEGIN
    SET @initial_sem = CASE 
        WHEN MONTH(NEW.intakeDate) >= 8 OR MONTH(NEW.intakeDate) <= 2 THEN 1
        ELSE 2
    END;
    INSERT INTO studentcourse (matricNo, courseCode)
    SELECT NEW.matricNo, c.courseCode
    FROM course c
    WHERE c.courseStatus = 'Core'
      AND c.yearOfStudy = 1             
      AND c.semesterTarget = @initial_sem;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `studentcourse`
--

CREATE TABLE `studentcourse` (
  `matricNo` varchar(20) NOT NULL,
  `courseCode` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `studentcourse`
--

INSERT INTO `studentcourse` (`matricNo`, `courseCode`) VALUES
('S001', 'CSE3203'),
('S001', 'CSF3043'),
('S001', 'CSF3213'),
('S001', 'MTK3053'),
('S002', 'CSF3003'),
('S002', 'CSF3023'),
('S002', 'CSF3034'),
('S002', 'CSF3143'),
('S002', 'CSF3243'),
('S003', 'CSF3003'),
('S003', 'CSF3023'),
('S003', 'CSF3034'),
('S003', 'CSF3143'),
('S003', 'CSF3243'),
('S004', 'CSF3003'),
('S004', 'CSF3023'),
('S004', 'CSF3034'),
('S004', 'CSF3143'),
('S004', 'CSF3243'),
('S005', 'CSF3003'),
('S005', 'CSF3023'),
('S005', 'CSF3034'),
('S005', 'CSF3143'),
('S005', 'CSF3243'),
('S006', 'CSF3003'),
('S006', 'CSF3023'),
('S006', 'CSF3034'),
('S006', 'CSF3143'),
('S006', 'CSF3243'),
('S007', 'CSF3003'),
('S007', 'CSF3023'),
('S007', 'CSF3034'),
('S007', 'CSF3143'),
('S007', 'CSF3243'),
('S008', 'CSF3003'),
('S008', 'CSF3023'),
('S008', 'CSF3034'),
('S008', 'CSF3143'),
('S008', 'CSF3243'),
('S009', 'CSF3003'),
('S009', 'CSF3023'),
('S009', 'CSF3034'),
('S009', 'CSF3143'),
('S009', 'CSF3243'),
('S010', 'CSF3003'),
('S010', 'CSF3023'),
('S010', 'CSF3034'),
('S010', 'CSF3143'),
('S010', 'CSF3243'),
('S011', 'CSF3003'),
('S011', 'CSF3023'),
('S011', 'CSF3034'),
('S011', 'CSF3143'),
('S011', 'CSF3243'),
('S012', 'CSF3003'),
('S012', 'CSF3023'),
('S012', 'CSF3034'),
('S012', 'CSF3143'),
('S012', 'CSF3243'),
('S013', 'CSF3003'),
('S013', 'CSF3023'),
('S013', 'CSF3034'),
('S013', 'CSF3143'),
('S013', 'CSF3243'),
('S014', 'CSF3003'),
('S014', 'CSF3023'),
('S014', 'CSF3034'),
('S014', 'CSF3143'),
('S014', 'CSF3243'),
('S015', 'CSF3003'),
('S015', 'CSF3023'),
('S015', 'CSF3034'),
('S015', 'CSF3143'),
('S015', 'CSF3243');

-- --------------------------------------------------------

--
-- Table structure for table `systemrule`
--

CREATE TABLE `systemrule` (
  `ruleId` int(11) NOT NULL,
  `attendanceThreshold` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `systemrule`
--

INSERT INTO `systemrule` (`ruleId`, `attendanceThreshold`) VALUES
(1, 80);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `matricNo` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `fullName` varchar(150) NOT NULL,
  `role` varchar(20) NOT NULL,
  `facultyName` varchar(10) NOT NULL,
  `email` varchar(250) NOT NULL,
  `phoneNo` varchar(20) DEFAULT NULL,
  `profilePhoto` longblob DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`matricNo`, `password`, `fullName`, `role`, `facultyName`, `email`, `phoneNo`, `profilePhoto`) VALUES
('A001', '123', 'Admin', 'Admin', 'PPPA', 'admin@edu.my', NULL, NULL),
('L001', '123', 'Dr. Smith', 'lecturer', 'FSKM', 'smith@university.edu', NULL, NULL),
('L002', '123', 'Dr. Ariff', 'lecturer', 'FSKM', 'ariff@university.edu', NULL, NULL),
('L003', '123', 'Dr. Siti', 'lecturer', 'FSKM', 'siti@university.edu', NULL, NULL),
('L004', '123', 'Dr. Razak', 'lecturer', 'FSKM', 'razak@university.edu', NULL, NULL),
('L005', '123', 'Dr. Hidayah', 'lecturer', 'FSKM', 'hidayah@university.edu', NULL, NULL),
('L006', '123', 'Dr. Tan', 'lecturer', 'FSKM', 'tan@university.edu', NULL, NULL),
('L007', '123', 'Dr. Wong', 'lecturer', 'FSKM', 'wong@university.edu', NULL, NULL),
('L008', '123', 'Dr. Zaki', 'lecturer', 'FSKM', 'zaki@university.edu', NULL, NULL),
('L009', '123', 'Dr. Yusof', 'lecturer', 'FSKM', 'yusof@university.edu', NULL, NULL),
('L010', '123', 'Dr. Rahim', 'lecturer', 'FSKM', 'rahim@university.edu', NULL, NULL),
('S001', '123', 'Asif', 'student', 'FSKM', 'asif@student.edu', NULL, NULL),
('S002', '123', 'Budi', 'student', 'FSKM', 'budi@student.edu', NULL, NULL),
('S003', '123', 'Chia', 'student', 'FSKM', 'chia@student.edu', NULL, NULL),
('S004', '123', 'Danial', 'student', 'FSKM', 'danial@student.edu', NULL, NULL),
('S005', '123', 'Ezzah', 'student', 'FSKM', 'ezzah@student.edu', NULL, NULL),
('S006', '123', 'Farah', 'student', 'FSKM', 'farah@student.edu', NULL, NULL),
('S007', '123', 'Gopal', 'student', 'FSKM', 'gopal@student.edu', NULL, NULL),
('S008', '123', 'Hana', 'student', 'FSKM', 'hana@student.edu', NULL, NULL),
('S009', '123', 'Irfan', 'student', 'FSKM', 'irfan@student.edu', NULL, NULL),
('S010', '123', 'Jasmine', 'student', 'FSKM', 'jasmine@student.edu', NULL, NULL),
('S011', '123', 'Kumar', 'student', 'FSKM', 'kumar@student.edu', NULL, NULL),
('S012', '123', 'Lina', 'student', 'FSKM', 'lina@student.edu', NULL, NULL),
('S013', '123', 'Maya', 'student', 'FSKM', 'maya@student.edu', NULL, NULL),
('S014', '123', 'Nizam', 'student', 'FSKM', 'nizam@student.edu', NULL, NULL),
('S015', '123', 'Olivia', 'student', 'FSKM', 'olivia@student.edu', NULL, NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_student_current_status`
-- (See below for the actual view)
--
CREATE TABLE `v_student_current_status` (
`matricNo` varchar(20)
,`programmeId` varchar(10)
,`intakeDate` date
,`intakeSession` varchar(20)
,`intakeSemester` varchar(20)
,`currentSession` varchar(10)
,`currentLevel` varchar(27)
);

-- --------------------------------------------------------

--
-- Structure for view `v_student_current_status`
--
DROP TABLE IF EXISTS `v_student_current_status`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_student_current_status`  AS SELECT `s`.`matricNo` AS `matricNo`, `s`.`programmeId` AS `programmeId`, `s`.`intakeDate` AS `intakeDate`, `s`.`session` AS `intakeSession`, `s`.`semester` AS `intakeSemester`, CASE WHEN month(curdate()) >= 10 THEN concat(year(curdate()),'/',year(curdate()) + 1) ELSE concat(year(curdate()) - 1,'/',year(curdate())) END AS `currentSession`, concat(case when `s`.`intakeDate` > curdate() then '1st Year' when floor(period_diff(extract(year_month from curdate()),extract(year_month from `s`.`intakeDate`)) / 12) + 1 = 1 then '1st Year' when floor(period_diff(extract(year_month from curdate()),extract(year_month from `s`.`intakeDate`)) / 12) + 1 = 2 then '2nd Year' when floor(period_diff(extract(year_month from curdate()),extract(year_month from `s`.`intakeDate`)) / 12) + 1 = 3 then '3rd Year' else '4th Year+' end,' (',case when `s`.`intakeDate` > curdate() then 'Upcoming Sem 1' when month(curdate()) >= 10 or month(curdate()) <= 2 then 'Sem 1' when month(curdate()) >= 3 and month(curdate()) <= 7 then 'Sem 2' else case when year(`s`.`intakeDate`) = year(curdate()) and month(`s`.`intakeDate`) >= 8 then 'Sem 1 Induction' else 'Sem 2 Break' end end,')') AS `currentLevel` FROM `student` AS `s` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `absenceleave`
--
ALTER TABLE `absenceleave`
  ADD PRIMARY KEY (`leaveId`),
  ADD KEY `absenceleave_ibfk_1` (`matricNo`),
  ADD KEY `absenceleave_ibfk_2` (`courseCode`);

--
-- Indexes for table `attendancerecord`
--
ALTER TABLE `attendancerecord`
  ADD PRIMARY KEY (`recordId`),
  ADD KEY `attendancerecord_ibfk_1` (`sessionId`),
  ADD KEY `attendancerecord_ibfk_2` (`matricNo`);

--
-- Indexes for table `attendancesession`
--
ALTER TABLE `attendancesession`
  ADD PRIMARY KEY (`sessionId`),
  ADD KEY `attendancesession_ibfk_1` (`courseCode`),
  ADD KEY `attendancesession_ibfk_2` (`matricNo`);

--
-- Indexes for table `course`
--
ALTER TABLE `course`
  ADD PRIMARY KEY (`courseCode`),
  ADD KEY `course_ibfk_1` (`facultyName`);

--
-- Indexes for table `faculty`
--
ALTER TABLE `faculty`
  ADD PRIMARY KEY (`facultyName`);

--
-- Indexes for table `lecturer`
--
ALTER TABLE `lecturer`
  ADD PRIMARY KEY (`matricNo`);

--
-- Indexes for table `lecturercourse`
--
ALTER TABLE `lecturercourse`
  ADD PRIMARY KEY (`matricNo`,`courseCode`),
  ADD KEY `lecturercourse_ibfk_2` (`courseCode`);

--
-- Indexes for table `programme`
--
ALTER TABLE `programme`
  ADD PRIMARY KEY (`programmeId`),
  ADD KEY `programme_ibfk_1` (`facultyName`);

--
-- Indexes for table `student`
--
ALTER TABLE `student`
  ADD PRIMARY KEY (`matricNo`),
  ADD KEY `student_ibfk_2` (`programmeId`);

--
-- Indexes for table `studentcourse`
--
ALTER TABLE `studentcourse`
  ADD PRIMARY KEY (`matricNo`,`courseCode`),
  ADD KEY `studentcourse_ibfk_2` (`courseCode`);

--
-- Indexes for table `systemrule`
--
ALTER TABLE `systemrule`
  ADD PRIMARY KEY (`ruleId`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`matricNo`),
  ADD KEY `users_ibfk_1` (`facultyName`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `absenceleave`
--
ALTER TABLE `absenceleave`
  ADD CONSTRAINT `absenceleave_ibfk_1` FOREIGN KEY (`matricNo`) REFERENCES `student` (`matricNo`) ON DELETE CASCADE,
  ADD CONSTRAINT `absenceleave_ibfk_2` FOREIGN KEY (`courseCode`) REFERENCES `course` (`courseCode`) ON DELETE CASCADE;

--
-- Constraints for table `attendancerecord`
--
ALTER TABLE `attendancerecord`
  ADD CONSTRAINT `attendancerecord_ibfk_1` FOREIGN KEY (`sessionId`) REFERENCES `attendancesession` (`sessionId`) ON DELETE CASCADE,
  ADD CONSTRAINT `attendancerecord_ibfk_2` FOREIGN KEY (`matricNo`) REFERENCES `student` (`matricNo`);

--
-- Constraints for table `attendancesession`
--
ALTER TABLE `attendancesession`
  ADD CONSTRAINT `attendancesession_ibfk_1` FOREIGN KEY (`courseCode`) REFERENCES `course` (`courseCode`) ON DELETE CASCADE,
  ADD CONSTRAINT `attendancesession_ibfk_2` FOREIGN KEY (`matricNo`) REFERENCES `lecturer` (`matricNo`);

--
-- Constraints for table `course`
--
ALTER TABLE `course`
  ADD CONSTRAINT `course_ibfk_1` FOREIGN KEY (`facultyName`) REFERENCES `faculty` (`facultyName`);

--
-- Constraints for table `lecturer`
--
ALTER TABLE `lecturer`
  ADD CONSTRAINT `lecturer_ibfk_1` FOREIGN KEY (`matricNo`) REFERENCES `users` (`matricNo`);

--
-- Constraints for table `lecturercourse`
--
ALTER TABLE `lecturercourse`
  ADD CONSTRAINT `lecturercourse_ibfk_1` FOREIGN KEY (`matricNo`) REFERENCES `lecturer` (`matricNo`),
  ADD CONSTRAINT `lecturercourse_ibfk_2` FOREIGN KEY (`courseCode`) REFERENCES `course` (`courseCode`) ON DELETE CASCADE;

--
-- Constraints for table `programme`
--
ALTER TABLE `programme`
  ADD CONSTRAINT `programme_ibfk_1` FOREIGN KEY (`facultyName`) REFERENCES `faculty` (`facultyName`) ON UPDATE CASCADE;

--
-- Constraints for table `student`
--
ALTER TABLE `student`
  ADD CONSTRAINT `student_ibfk_1` FOREIGN KEY (`matricNo`) REFERENCES `users` (`matricNo`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_ibfk_2` FOREIGN KEY (`programmeId`) REFERENCES `programme` (`programmeId`);

--
-- Constraints for table `studentcourse`
--
ALTER TABLE `studentcourse`
  ADD CONSTRAINT `studentcourse_ibfk_1` FOREIGN KEY (`matricNo`) REFERENCES `student` (`matricNo`),
  ADD CONSTRAINT `studentcourse_ibfk_2` FOREIGN KEY (`courseCode`) REFERENCES `course` (`courseCode`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`facultyName`) REFERENCES `faculty` (`facultyName`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
