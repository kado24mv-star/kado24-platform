package com.kado24.redemption;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = {"com.kado24.redemption", "com.kado24.common", "com.kado24.security", "com.kado24.kafka"})
public class RedemptionServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(RedemptionServiceApplication.class, args);
    }
}






































