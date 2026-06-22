package util;

import java.time.LocalDate;
import java.time.Period;

public class AcademicTracker {

    /**
     * Structure to hold dynamic calculations neatly
     */
    public static class AcademicStatus {

        public String batchSession;    // e.g., "2024/2025"
        public int academicYear;       // e.g., 1, 2, 3
        public int semester;           // e.g., 1, 2

        @Override
        public String toString() {
            String yearNames[] = {"", "First Year", "Second Year", "Third Year", "Fourth Year"};
            String semNames[] = {"", "First Semester", "Second Semester"};

            String yrStr = (academicYear <= 4) ? yearNames[academicYear] : "Year " + academicYear;
            String semStr = (semester <= 2) ? semNames[semester] : "Semester " + semester;

            return "Batch " + batchSession + " (" + yrStr + " " + semStr + ")";
        }
    }

    public static AcademicStatus calculateCurrentStatus(LocalDate intakeDate) {
        LocalDate today = LocalDate.now();
        AcademicStatus status = new AcademicStatus();

        // 1. Determine current calendar execution limits
        int currentYear = today.getYear();
        int currentMonth = today.getMonthValue();

        int intakeYear = intakeDate.getYear();

        // 2. Map dynamic current Batch Session arrays
        // Semester 1: October (10) to February (2)
        // Semester 2: March (3) to July (7)
        // Aug & Sept are typical vacation/resit months - grouped with previous academic session cycle
        if (currentMonth >= 10) {
            status.batchSession = currentYear + "/" + (currentYear + 1);
        } else {
            status.batchSession = (currentYear - 1) + "/" + currentYear;
        }

        // 3. Calculate Academic Year progress tracking boundaries
        // Year increments based on how many full 12-month periods have passed since intake October
        int absoluteYearsPassed = Period.between(intakeDate, today).getYears();
        status.academicYear = absoluteYearsPassed + 1; // Starts at Year 1

        // 4. Determine Semester phase based on active month windows
        // Semester 1: Oct (10), Nov (11), Dec (12), Jan (1), Feb (2)
        if (currentMonth >= 10 || currentMonth <= 2) {
            status.semester = 1;
        } else {
            // Semester 2: Mar (3), Apr (4), May (5), Jun (6), Jul (7)
            // (Aug/Sept default to Semester 2 terms for simplicity before next tier cycle starts)
            status.semester = 2;
        }

        return status;
    }
}
