package com.joalifemall.demo;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequiredArgsConstructor
public class IndexController {

	
	@GetMapping("/")
	public String index() {
		log.info("Welcome to the world!!");
		
		return "index";
	}
	@GetMapping("/f/match/client/no")
	public String matchClientNo() {
		
		return "feature/matchClientNo";
	}

	
}
