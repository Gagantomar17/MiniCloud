package com.EkAnek.MiniCloud.controller;

import com.EkAnek.MiniCloud.entity.FileRecord;
import com.EkAnek.MiniCloud.repository.FileRecordRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;

@RestController
@RequestMapping("/public")
@RequiredArgsConstructor
public class PublicController {
    private final FileRecordRepository fileRepo;
    @Value("${file.upload-dir}")
    private String uploadDir;

    @GetMapping("/{tinyUrl}")
    public ResponseEntity<Resource> download(@PathVariable String tinyUrl) throws IOException {
        var record = fileRepo.findByTinyUrl(tinyUrl)
                      .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        Path path = Paths.get(uploadDir, record.getFileName());
        Resource resource = new UrlResource(path.toUri());
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + record.getTitle() + "\"")
                .body(resource);
    }
}