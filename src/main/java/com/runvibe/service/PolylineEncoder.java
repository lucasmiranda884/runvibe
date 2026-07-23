package com.runvibe.service;

import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class PolylineEncoder {

    public String encode(List<GeoCalculationService.GeoPoint> points) {
        StringBuilder encoded = new StringBuilder();
        long previousLatitude = 0;
        long previousLongitude = 0;

        for (GeoCalculationService.GeoPoint point : points) {
            long latitude = Math.round(point.latitude() * 1e5);
            long longitude = Math.round(point.longitude() * 1e5);
            encodeSigned(latitude - previousLatitude, encoded);
            encodeSigned(longitude - previousLongitude, encoded);
            previousLatitude = latitude;
            previousLongitude = longitude;
        }
        return encoded.toString();
    }

    private void encodeSigned(long value, StringBuilder target) {
        long shifted = value << 1;
        if (value < 0) shifted = ~shifted;
        while (shifted >= 0x20) {
            target.append((char) ((0x20 | (shifted & 0x1f)) + 63));
            shifted >>= 5;
        }
        target.append((char) (shifted + 63));
    }
}
