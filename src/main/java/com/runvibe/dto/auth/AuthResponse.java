package com.runvibe.dto.auth;

import java.util.UUID;

public record AuthResponse(String accessToken, String tokenType, long expiresInSeconds,
                           UUID userId, String name, String email) {
}
