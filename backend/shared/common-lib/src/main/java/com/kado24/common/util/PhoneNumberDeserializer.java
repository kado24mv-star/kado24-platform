package com.kado24.common.util;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;

import java.io.IOException;

/**
 * Custom Jackson deserializer for phone numbers
 * Normalizes phone numbers to +855 format during JSON deserialization
 * This ensures normalization happens before validation annotations are processed
 */
public class PhoneNumberDeserializer extends JsonDeserializer<String> {
    
    @Override
    public String deserialize(JsonParser p, DeserializationContext ctxt) throws IOException {
        String phoneNumber = p.getValueAsString();
        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            return null;
        }
        
        // Normalize the phone number
        String normalized = PhoneNumberUtil.normalize(phoneNumber);
        
        // If normalization failed (returns null), return the original value
        // This allows validation annotations to handle the error with a clear message
        return normalized != null ? normalized : phoneNumber;
    }
}

