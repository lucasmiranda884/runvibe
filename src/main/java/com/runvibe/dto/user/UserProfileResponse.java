package com.runvibe.dto.user;

import java.time.Instant;
import java.util.UUID;

public record UserProfileResponse(
        UUID id,
        String name,
        String email,
        String bio,
        String profilePictureUrl,
        Instant createdAt,
        long followers,
        long following,
        boolean followedByMe
) {
}
