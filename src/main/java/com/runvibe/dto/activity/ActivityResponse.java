package com.runvibe.dto.activity;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record ActivityResponse(
        UUID id,
        UUID userId,
        String userName,
        String title,
        String description,
        String sportType,
        double totalDistanceMeters,
        int elapsedTimeSeconds,
        int movingTimeSeconds,
        int averagePaceSecondsPerKm,
        double elevationGainMeters,
        UUID shoeId,
        String shoeName,
        String routePolyline,
        Instant createdAt,
        List<SplitResponse> splits
) {
}
