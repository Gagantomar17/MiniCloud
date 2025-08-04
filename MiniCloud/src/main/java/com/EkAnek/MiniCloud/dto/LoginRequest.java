package com.EkAnek.MiniCloud.dto;

import lombok.Data;

@Data
public class LoginRequest {
    private String email, password;
}