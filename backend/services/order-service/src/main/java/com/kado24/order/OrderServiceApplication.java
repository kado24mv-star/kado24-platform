package com.kado24.order;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * Order Service Application
 */
@SpringBootApplication
@EnableJpaRepositories
@ComponentScan(basePackages = {
        "com.kado24.order",
        "com.kado24.common",
        "com.kado24.security",
        "com.kado24.kafka"
})
public class OrderServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(OrderServiceApplication.class, args);
    }
}






































