package com.EkAnek.MiniCloud.dto;

import lombok.Data;

@Data
public class RegisterRequest {
    private String email, password;
}