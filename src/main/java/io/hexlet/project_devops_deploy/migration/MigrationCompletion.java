package io.hexlet.project_devops_deploy.migration;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Profile;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

@Component
@Profile("migration")
@Order(Ordered.LOWEST_PRECEDENCE)
@RequiredArgsConstructor
public class MigrationCompletion implements ApplicationRunner {

    private final ConfigurableApplicationContext applicationContext;

    @Override
    public void run(ApplicationArguments args) {
        applicationContext.close();
    }
}
