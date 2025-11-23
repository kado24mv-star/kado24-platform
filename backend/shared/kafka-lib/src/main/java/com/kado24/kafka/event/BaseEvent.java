package com.kado24.kafka.event;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Base class for all Kafka events
 */
@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public abstract class BaseEvent {
    
    /**
     * Unique event identifier
     */
    private String eventId;
    
    /**
     * Event type identifier
     */
    private String eventType;
    
    /**
     * Event timestamp
     */
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime timestamp;
    
    /**
     * Source service that generated this event
     */
    private String source;
    
    /**
     * Event version for schema evolution
     */
    private String version;

    /**
     * Initialize event with defaults
     */
    public void initDefaults(String eventType, String source) {
        if (this.eventId == null) {
            this.eventId = UUID.randomUUID().toString();
        }
        if (this.timestamp == null) {
            this.timestamp = LocalDateTime.now();
        }
        if (this.version == null) {
            this.version = "1.0";
        }
        this.eventType = eventType;
        this.source = source;
    }
}






































