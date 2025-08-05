package com.EkAnek.MiniCloud.controller;

import com.EkAnek.MiniCloud.entity.FileRecord;
import com.EkAnek.MiniCloud.entity.User;
import com.EkAnek.MiniCloud.repository.UserRepository;
import com.EkAnek.MiniCloud.service.FileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.security.Principal;

@RestController
@RequestMapping("/files")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class FileController {
    private final FileService fileService;
    private final UserRepository userRepo;

    @PostMapping("/upload")
    public ResponseEntity<?> uploadFile(@RequestParam("file") MultipartFile file,
                                        @RequestParam("title") String title,
                                        @RequestParam(value = "desc", required = false) String description,
                                        Principal principal) throws IOException {
        try {
            var user = userRepo.findByEmail(principal.getName()).orElseThrow();
            FileRecord fr = fileService.saveFile(file, title, description, user);
            return ResponseEntity.ok(fr);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Upload failed: " + e.getMessage());
        }
    }

    @GetMapping("/my-files")
    public ResponseEntity<?> listMyFiles(Principal principal) {
        try {
            var user = userRepo.findByEmail(principal.getName()).orElseThrow();
            return ResponseEntity.ok(fileService.getFilesByUser(user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Failed to load files: " + e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteFile(@PathVariable Long id, Principal principal) throws IOException {
        try {
            var user = userRepo.findByEmail(principal.getName()).orElseThrow();
            fileService.deleteFile(id, user);
            return ResponseEntity.ok("File deleted successfully");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Delete failed: " + e.getMessage());
        }
    }

    @PostMapping("/{id}/share")
    public ResponseEntity<?> shareFile(@PathVariable Long id, Principal principal) {
        try {
            var user = userRepo.findByEmail(principal.getName()).orElseThrow();
            FileRecord fr = fileService.shareFile(id, user);
            return ResponseEntity.ok(fr);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Share failed: " + e.getMessage());
        }
    }

    @GetMapping("/{id}/public-url")
    public ResponseEntity<?> getPublicUrl(@PathVariable Long id, Principal principal) {
        try {
            var user = userRepo.findByEmail(principal.getName()).orElseThrow();
            FileRecord fr = fileService.getFileById(id, user);
            if (fr.getTinyUrl() != null) {
                return ResponseEntity.ok(fr);
            } else {
                return ResponseEntity.ok("File not shared yet");
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Failed to get public URL: " + e.getMessage());
        }
    }

    @DeleteMapping("/{id}/share")
    public ResponseEntity<?> revokeShare(@PathVariable Long id, Principal principal) {
        try {
            var user = userRepo.findByEmail(principal.getName()).orElseThrow();
            FileRecord fr = fileService.revokeShare(id, user);
            return ResponseEntity.ok("File sharing revoked successfully");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Revoke failed: " + e.getMessage());
        }
    }
}
