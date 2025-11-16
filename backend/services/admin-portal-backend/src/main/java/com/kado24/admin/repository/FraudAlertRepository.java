package com.kado24.admin.repository;

import com.kado24.admin.entity.FraudAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FraudAlertRepository extends JpaRepository<FraudAlert, Long> {
    List<FraudAlert> findByStatusOrderByCreatedAtDesc(String status);
    List<FraudAlert> findBySeverityOrderByCreatedAtDesc(String severity);
}

