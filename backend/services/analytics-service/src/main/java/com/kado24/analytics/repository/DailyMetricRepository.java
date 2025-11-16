package com.kado24.analytics.repository;

import com.kado24.analytics.entity.DailyMetric;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface DailyMetricRepository extends JpaRepository<DailyMetric, Long> {
    Optional<DailyMetric> findByMetricDate(LocalDate metricDate);
    List<DailyMetric> findByMetricDateBetweenOrderByMetricDateDesc(LocalDate startDate, LocalDate endDate);
}













