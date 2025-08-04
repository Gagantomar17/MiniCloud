package com.EkAnek.MiniCloud.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FileRecord {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    private String title;
    private String description;
    private String fileName;
    private String fileType;
    private Boolean compressed = false;
    private String tinyUrl;
    private Long fileSize;

    private LocalDateTime uploadedAt = LocalDateTime.now();
}
