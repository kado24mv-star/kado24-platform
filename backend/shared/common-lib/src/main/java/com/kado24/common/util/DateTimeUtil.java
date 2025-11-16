package com.kado24.common.util;

import java.time.*;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

/**
 * Utility class for date and time operations
 */
public final class DateTimeUtil {
    
    private DateTimeUtil() {
        throw new UnsupportedOperationException("Utility class");
    }
    
    public static final DateTimeFormatter ISO_DATE_TIME = DateTimeFormatter.ISO_DATE_TIME;
    public static final DateTimeFormatter ISO_DATE = DateTimeFormatter.ISO_DATE;
    public static final DateTimeFormatter DISPLAY_DATE_TIME = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    public static final DateTimeFormatter DISPLAY_DATE = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    
    public static final ZoneId CAMBODIA_ZONE = ZoneId.of("Asia/Phnom_Penh");
    
    /**
     * Get current date time in Cambodia timezone
     */
    public static LocalDateTime nowInCambodia() {
        return LocalDateTime.now(CAMBODIA_ZONE);
    }
    
    /**
     * Get current date in Cambodia timezone
     */
    public static LocalDate todayInCambodia() {
        return LocalDate.now(CAMBODIA_ZONE);
    }
    
    /**
     * Convert LocalDateTime to Cambodia timezone
     */
    public static ZonedDateTime toCambodiaTime(LocalDateTime dateTime) {
        return dateTime.atZone(CAMBODIA_ZONE);
    }
    
    /**
     * Check if a date is in the past
     */
    public static boolean isPast(LocalDateTime dateTime) {
        return dateTime.isBefore(nowInCambodia());
    }
    
    /**
     * Check if a date is in the future
     */
    public static boolean isFuture(LocalDateTime dateTime) {
        return dateTime.isAfter(nowInCambodia());
    }
    
    /**
     * Check if current time is between start and end
     */
    public static boolean isBetween(LocalDateTime start, LocalDateTime end) {
        LocalDateTime now = nowInCambodia();
        return !now.isBefore(start) && !now.isAfter(end);
    }
    
    /**
     * Get start of day
     */
    public static LocalDateTime startOfDay(LocalDate date) {
        return date.atStartOfDay();
    }
    
    /**
     * Get end of day
     */
    public static LocalDateTime endOfDay(LocalDate date) {
        return date.atTime(LocalTime.MAX);
    }
    
    /**
     * Get start of week (Monday)
     */
    public static LocalDate startOfWeek(LocalDate date) {
        return date.with(DayOfWeek.MONDAY);
    }
    
    /**
     * Get end of week (Sunday)
     */
    public static LocalDate endOfWeek(LocalDate date) {
        return date.with(DayOfWeek.SUNDAY);
    }
    
    /**
     * Get start of month
     */
    public static LocalDate startOfMonth(LocalDate date) {
        return date.withDayOfMonth(1);
    }
    
    /**
     * Get end of month
     */
    public static LocalDate endOfMonth(LocalDate date) {
        return date.withDayOfMonth(date.lengthOfMonth());
    }
    
    /**
     * Calculate days between two dates
     */
    public static long daysBetween(LocalDate start, LocalDate end) {
        return ChronoUnit.DAYS.between(start, end);
    }
    
    /**
     * Calculate hours between two date times
     */
    public static long hoursBetween(LocalDateTime start, LocalDateTime end) {
        return ChronoUnit.HOURS.between(start, end);
    }
    
    /**
     * Add days to a date
     */
    public static LocalDate addDays(LocalDate date, long days) {
        return date.plusDays(days);
    }
    
    /**
     * Add hours to a date time
     */
    public static LocalDateTime addHours(LocalDateTime dateTime, long hours) {
        return dateTime.plusHours(hours);
    }
    
    /**
     * Format date time for display
     */
    public static String formatForDisplay(LocalDateTime dateTime) {
        return dateTime.format(DISPLAY_DATE_TIME);
    }
    
    /**
     * Format date for display
     */
    public static String formatForDisplay(LocalDate date) {
        return date.format(DISPLAY_DATE);
    }
    
    /**
     * Parse ISO date time string
     */
    public static LocalDateTime parseIsoDateTime(String dateTimeStr) {
        return LocalDateTime.parse(dateTimeStr, ISO_DATE_TIME);
    }
    
    /**
     * Parse ISO date string
     */
    public static LocalDate parseIsoDate(String dateStr) {
        return LocalDate.parse(dateStr, ISO_DATE);
    }
}



















