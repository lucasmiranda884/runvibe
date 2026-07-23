package com.runvibe.service;

import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

@Service
public class GeoCalculationService {

    private static final double EARTH_RADIUS_METERS = 6_371_008.8;

    public RouteMetrics calculate(List<GeoPoint> points, int movingTimeSeconds) {
        if (points.size() < 2) {
            throw new IllegalArgumentException("A corrida deve conter ao menos dois pontos GPS");
        }

        double totalDistance = 0;
        double elevationGain = 0;
        double distanceAtLastSplit = 0;
        int splitNumber = 1;
        List<Split> splits = new ArrayList<>();

        for (int i = 1; i < points.size(); i++) {
            GeoPoint previous = points.get(i - 1);
            GeoPoint current = points.get(i);
            double segment = haversineMeters(previous.latitude(), previous.longitude(),
                    current.latitude(), current.longitude());
            totalDistance += segment;

            if (previous.elevation() != null && current.elevation() != null) {
                elevationGain += Math.max(0, current.elevation() - previous.elevation());
            }

            while (totalDistance >= splitNumber * 1_000.0) {
                double target = splitNumber * 1_000.0;
                double fraction = segment == 0 ? 0 : (target - (totalDistance - segment)) / segment;
                long segmentMillis = Duration.between(previous.timestamp(), current.timestamp()).toMillis();
                long targetMillis = previous.timestamp().toEpochMilli() + Math.round(segmentMillis * fraction);
                long startMillis = splitNumber == 1
                        ? points.getFirst().timestamp().toEpochMilli()
                        : splits.getLast().reachedAtEpochMilli();
                splits.add(new Split(splitNumber, target - distanceAtLastSplit,
                        Math.max(0, Math.toIntExact((targetMillis - startMillis) / 1_000)), targetMillis));
                distanceAtLastSplit = target;
                splitNumber++;
            }
        }

        int pace = totalDistance <= 0 ? 0 : (int) Math.round(movingTimeSeconds / (totalDistance / 1_000.0));
        return new RouteMetrics(totalDistance, elevationGain, pace, List.copyOf(splits));
    }

    public double haversineMeters(double lat1, double lon1, double lat2, double lon2) {
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        return EARTH_RADIUS_METERS * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    public record GeoPoint(double latitude, double longitude, Double elevation,
                           java.time.Instant timestamp) {
    }

    public record Split(int kilometer, double distanceMeters, int durationSeconds,
                        long reachedAtEpochMilli) {
    }

    public record RouteMetrics(double distanceMeters, double elevationGainMeters,
                               int averagePaceSecondsPerKm, List<Split> splits) {
    }
}
