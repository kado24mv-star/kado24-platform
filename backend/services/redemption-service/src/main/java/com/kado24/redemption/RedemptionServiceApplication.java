package com.kado24.redemption;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = {"com.kado24.redemption", "com.kado24.common", "com.kado24.security", "com.kado24.kafka"})
public class RedemptionServiceApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(RedemptionServiceApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(RedemptionServiceApplication.class, args);
    }
}






































