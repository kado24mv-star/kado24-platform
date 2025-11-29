package com.kado24.merchant;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * Merchant Service Application
 */
@SpringBootApplication
@EnableJpaRepositories
@ComponentScan(basePackages = {
        "com.kado24.merchant",
        "com.kado24.common",
        "com.kado24.security",
        "com.kado24.kafka"
})
public class MerchantServiceApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(MerchantServiceApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(MerchantServiceApplication.class, args);
    }
}






































