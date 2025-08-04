package com.EkAnek.MiniCloud.controller;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

@RestController
public class FrontendController {

    @GetMapping("/")
    public ResponseEntity<Resource> index() throws IOException {
        Resource resource = new ClassPathResource("static/index.html");
        return ResponseEntity.ok()
                .contentType(MediaType.TEXT_HTML)
                .body(resource);
    }

    @GetMapping("/index.html")
    public ResponseEntity<Resource> indexHtml() throws IOException {
        Resource resource = new ClassPathResource("static/index.html");
        return ResponseEntity.ok()
                .contentType(MediaType.TEXT_HTML)
                .body(resource);
    }

    @GetMapping("/styles.css")
    public ResponseEntity<Resource> styles() throws IOException {
        Resource resource = new ClassPathResource("static/styles.css");
        return ResponseEntity.ok()
                .contentType(MediaType.valueOf("text/css"))
                .body(resource);
    }

    @GetMapping("/script.js")
    public ResponseEntity<Resource> script() throws IOException {
        Resource resource = new ClassPathResource("static/script.js");
        return ResponseEntity.ok()
                .contentType(MediaType.valueOf("application/javascript"))
                .body(resource);
    }
} 