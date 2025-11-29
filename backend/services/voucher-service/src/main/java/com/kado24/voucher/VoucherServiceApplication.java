package com.kado24.voucher;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * Voucher Service Application
 */
@SpringBootApplication
@EnableJpaRepositories
@EnableCaching
@ComponentScan(basePackages = {
        "com.kado24.voucher",
        "com.kado24.common",
        "com.kado24.security",
        "com.kado24.kafka"
})
public class VoucherServiceApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(VoucherServiceApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(VoucherServiceApplication.class, args);
    }
}







