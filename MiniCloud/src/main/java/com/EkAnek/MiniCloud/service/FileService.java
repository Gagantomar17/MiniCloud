package com.EkAnek.MiniCloud.service;

import com.EkAnek.MiniCloud.entity.FileRecord;
import com.EkAnek.MiniCloud.entity.User;
import com.EkAnek.MiniCloud.repository.FileRecordRepository;
import com.EkAnek.MiniCloud.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.apache.tika.Tika;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import org.springframework.security.access.AccessDeniedException;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FileService {
    private final FileRecordRepository fileRepo;
    private final UserRepository userRepo;

    @Value("${file.upload-dir}")
    private String uploadDir;

    public FileRecord saveFile(MultipartFile file, String title, String desc, User user) throws IOException {
        // Generate unique filename
        String rawFileName = UUID.randomUUID() + "-" + file.getOriginalFilename();
        Path filepath = Paths.get(uploadDir, rawFileName);

        Files.createDirectories(filepath.getParent());
        Files.copy(file.getInputStream(), filepath, StandardCopyOption.REPLACE_EXISTING);

        var fileType = new Tika().detect(filepath);
        FileRecord fr = new FileRecord();
        fr.setUser(user);
        fr.setTitle(title);
        fr.setDescription(desc);
        fr.setFileName(rawFileName);
        fr.setFileType(fileType);
        fr.setFileSize(file.getSize());
        fr.setCompressed(false); // compression logic can be added
        fileRepo.save(fr);
        return fr;
    }

    public List<FileRecord> getFilesByUser(User user) {
        return fileRepo.findByUser(user);
    }

    public void deleteFile(Long id, User user) throws IOException {
        var file = fileRepo.findById(id).orElseThrow();
        if (!file.getUser().getId().equals(user.getId())) throw new AccessDeniedException("Denied");
        Path path = Paths.get(uploadDir, file.getFileName());
        Files.deleteIfExists(path);
        fileRepo.delete(file);
    }

    public FileRecord shareFile(Long id, User user) {
        var file = fileRepo.findById(id).orElseThrow();
        if (!file.getUser().getId().equals(user.getId())) throw new AccessDeniedException("Denied");
        String tinyUrl = UUID.randomUUID().toString().substring(0, 8);
        file.setTinyUrl(tinyUrl);
        fileRepo.save(file);
        return file;
    }

    public FileRecord getFileById(Long id, User user) {
        var file = fileRepo.findById(id).orElseThrow();
        if (!file.getUser().getId().equals(user.getId())) throw new AccessDeniedException("Denied");
        return file;
    }

    public FileRecord revokeShare(Long id, User user) {
        var file = fileRepo.findById(id).orElseThrow();
        if (!file.getUser().getId().equals(user.getId())) throw new AccessDeniedException("Denied");
        file.setTinyUrl(null);
        fileRepo.save(file);
        return file;
    }
}