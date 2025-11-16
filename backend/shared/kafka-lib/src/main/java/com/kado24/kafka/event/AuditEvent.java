package com.kado24.kafka.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.util.Map;

/**
 * Event published for audit logging
 */
@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class AuditEvent extends BaseEvent {
    
    /**
     * User who performed the action
     */
    private Long userId;
    
    /**
     * Action performed
     */
    private String action;
    
    /**
     * Entity type affected
     */
    private String entityType;
    
    /**
     * Entity ID affected
     */
    private Long entityId;
    
    /**
     * Old values (before change)
     */
    private Map<String, Object> oldValues;
    
    /**
     * New values (after change)
     */
    private Map<String, Object> newValues;
    
    /**
     * IP address
     */
    private String ipAddress;
    
    /**
     * User agent
     */
    private String userAgent;
    
    /**
     * Additional context
     */
    private Map<String, Object> context;

    // Action types
    public static final String CREATE = "CREATE";
    public static final String UPDATE = "UPDATE";
    public static final String DELETE = "DELETE";
    public static final String LOGIN = "LOGIN";
    public static final String LOGOUT = "LOGOUT";
    public static final String APPROVE = "APPROVE";
    public static final String REJECT = "REJECT";

    /**
     * Create audit event for entity creation
     */
    public static AuditEvent create(Long userId, String entityType, Long entityId, 
                                   Map<String, Object> values, String ipAddress) {
        AuditEvent event = AuditEvent.builder()
                .userId(userId)
                .action(CREATE)
                .entityType(entityType)
                .entityId(entityId)
                .newValues(values)
                .ipAddress(ipAddress)
                .build();
        event.initDefaults(CREATE, "audit-service");
        return event;
    }

    /**
     * Create audit event for entity update
     */
    public static AuditEvent update(Long userId, String entityType, Long entityId,
                                   Map<String, Object> oldValues, Map<String, Object> newValues,
                                   String ipAddress) {
        AuditEvent event = AuditEvent.builder()
                .userId(userId)
                .action(UPDATE)
                .entityType(entityType)
                .entityId(entityId)
                .oldValues(oldValues)
                .newValues(newValues)
                .ipAddress(ipAddress)
                .build();
        event.initDefaults(UPDATE, "audit-service");
        return event;
    }
}



















