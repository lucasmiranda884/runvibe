package com.runvibe.service;

import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class PolylineEncoderTest {

    @Test
    void encodesGoogleReferencePolyline() {
        var points = List.of(
                point(38.5, -120.2),
                point(40.7, -120.95),
                point(43.252, -126.453)
        );

        assertThat(new PolylineEncoder().encode(points))
                .isEqualTo("_p~iF~ps|U_ulLnnqC_mqNvxq`@");
    }

    private GeoCalculationService.GeoPoint point(double latitude, double longitude) {
        return new GeoCalculationService.GeoPoint(latitude, longitude, null, Instant.EPOCH);
    }
}
