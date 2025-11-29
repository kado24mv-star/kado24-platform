package com.kado24.mock.payment;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

/**
 * Mock Payment Service Application
 * Simulates payment gateways for development and testing
 */
@SpringBootApplication
public class MockPaymentServiceApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(MockPaymentServiceApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(MockPaymentServiceApplication.class, args);
    }
}






































