package com.runvibe.service;

import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class GeoCalculationServiceTest {

    private final GeoCalculationService service = new GeoCalculationService();

    @Test
    void calculatesDistancePaceElevationAndSplit() {
        Instant start = Instant.parse("2026-01-01T10:00:00Z");
        var points = List.of(
                new GeoCalculationService.GeoPoint(0, 0, 10.0, start),
                new GeoCalculationService.GeoPoint(0, 0.009, 15.0, start.plusSeconds(300))
        );

        var result = service.calculate(points, 300);

        assertThat(result.distanceMeters()).isBetween(999.0, 1_002.0);
        assertThat(result.elevationGainMeters()).isEqualTo(5.0);
        assertThat(result.averagePaceSecondsPerKm()).isBetween(299, 301);
        assertThat(result.splits()).hasSize(1);
    }

    @Test
    void haversineReturnsZeroForSamePoint() {
        assertThat(service.haversineMeters(-23.55, -46.63, -23.55, -46.63)).isZero();
    }
}
