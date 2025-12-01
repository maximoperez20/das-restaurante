package ar.edu.ubp.das.rest;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = "ar.edu.ubp.das")
public class DasRestauranteRestApplication {

	public static void main(String[] args) {
		SpringApplication.run(DasRestauranteRestApplication.class, args);
	}

}
