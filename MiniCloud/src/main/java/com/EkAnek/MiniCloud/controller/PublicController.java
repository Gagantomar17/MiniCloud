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
                      .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "File not found or sharing has been revoked"));
        
        Path path = Paths.get(uploadDir, record.getFileName());
        Resource resource = new UrlResource(path.toUri());
        
        if (!resource.exists()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "File not found on server");
        }
        
        // Determine if file should be displayed inline or downloaded
        String disposition = shouldDisplayInline(record.getFileType()) ? "inline" : "attachment";
        
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, disposition + "; filename=\"" + record.getTitle() + "\"")
                .header(HttpHeaders.CONTENT_TYPE, record.getFileType())
                .body(resource);
    }
    
    private boolean shouldDisplayInline(String fileType) {
        if (fileType == null) return false;
        
        // File types that can be displayed inline in browsers
        return fileType.startsWith("text/") ||
               fileType.startsWith("image/") ||
               fileType.equals("application/pdf") ||
               fileType.equals("application/json") ||
               fileType.equals("application/xml") ||
               fileType.startsWith("audio/") ||
               fileType.startsWith("video/") ||
               fileType.equals("application/javascript") ||
               fileType.equals("text/css") ||
               fileType.equals("text/html");
    }
}