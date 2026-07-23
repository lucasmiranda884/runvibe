package com.runvibe.dto.activity;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;

import java.time.Instant;

public record GpsPointRequest(
        @DecimalMin("-90.0") @DecimalMax("90.0") double latitude,
        @DecimalMin("-180.0") @DecimalMax("180.0") double longitude,
        Double elevation,
        @PositiveOrZero Double speedMs,
        @Min(20) @Max(260) Integer heartRate,
        @NotNull Instant timestamp
) {
}
