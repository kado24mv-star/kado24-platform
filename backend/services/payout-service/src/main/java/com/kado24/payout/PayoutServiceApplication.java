package com.kado24.payout;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
@ComponentScan(basePackages = {"com.kado24"})
public class PayoutServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(PayoutServiceApplication.class, args);
    }
}
















