package com.runvibe.dto.activity;

public record SplitResponse(int kilometer, double distanceMeters, int durationSeconds,
                            int paceSecondsPerKm) {
}
