package com.runvibe.dto.activity;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.util.List;
import java.util.UUID;

public record CreateActivityRequest(
        @NotBlank @Size(max = 160) String title,
        @Size(max = 2000) String description,
        UUID shoeId,
        @Positive int elapsedTimeSeconds,
        @Positive int movingTimeSeconds,
        @NotNull @Size(min = 2, max = 100_000) List<@Valid GpsPointRequest> points
) {
}
