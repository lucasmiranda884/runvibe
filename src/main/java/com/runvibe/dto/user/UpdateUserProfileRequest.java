package com.runvibe.dto.user;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdateUserProfileRequest(
        @NotBlank @Size(max = 120) String name,
        @Size(max = 500) String bio,
        @Size(max = 2048) String profilePictureUrl
) {
}
