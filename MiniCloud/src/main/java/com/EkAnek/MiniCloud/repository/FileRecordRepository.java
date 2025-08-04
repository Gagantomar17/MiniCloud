package com.EkAnek.MiniCloud.repository;

import com.EkAnek.MiniCloud.entity.FileRecord;
import com.EkAnek.MiniCloud.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FileRecordRepository extends JpaRepository<FileRecord, Long> {
    List<FileRecord> findByUser(User user);
    Optional<FileRecord> findByTinyUrl(String tinyUrl);
}