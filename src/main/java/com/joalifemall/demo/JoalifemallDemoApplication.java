package com.joalifemall.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.ApplicationPidFileWriter;

@SpringBootApplication
public class JoalifemallDemoApplication {

	public static void main(String[] args) {
		//SpringApplication.run(JoalifemallDemoApplication.class, args);
		SpringApplication application = new SpringApplication(JoalifemallDemoApplication.class);
		application.addListeners(new ApplicationPidFileWriter());	//PID(Process ID 작성)
		application.run(args);
	}

}