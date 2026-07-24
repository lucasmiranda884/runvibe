package com.runvibe.service;

import com.runvibe.entity.Activity;
import com.runvibe.entity.ActivityGpsPoint;
import com.runvibe.entity.Shoe;
import com.runvibe.entity.User;
import com.runvibe.exception.ResourceNotFoundException;
import com.runvibe.repository.ActivityGpsPointRepository;
import com.runvibe.repository.ActivityRepository;
import com.runvibe.repository.ShoeRepository;
import com.runvibe.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ActivityService {

    private static final GeometryFactory GEOMETRY_FACTORY =
            new GeometryFactory(new PrecisionModel(), 4326);

    private final UserRepository userRepository;
    private final ShoeRepository shoeRepository;
    private final ActivityRepository activityRepository;
    private final ActivityGpsPointRepository gpsPointRepository;
    private final GeoCalculationService geoCalculationService;
    private final PolylineEncoder polylineEncoder;

    @Transactional
    public Activity create(UUID userId, CreateActivityCommand command) {
        validate(command);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuário não encontrado"));
        Shoe shoe = command.shoeId() == null ? null : shoeRepository
                .findOwnedByIdForUpdate(command.shoeId(), userId)
                .orElseThrow(() -> new ResourceNotFoundException("Tênis não encontrado para este usuário"));

        List<GeoCalculationService.GeoPoint> route = command.points().stream()
                .map(point -> new GeoCalculationService.GeoPoint(point.latitude(), point.longitude(),
                        point.elevation(), point.timestamp()))
                .toList();
        GeoCalculationService.RouteMetrics metrics =
                geoCalculationService.calculate(route, command.movingTimeSeconds());

        Activity activity = new Activity();
        activity.setUser(user);
        activity.setShoe(shoe);
        activity.setTitle(command.title().trim());
        activity.setDescription(command.description());
        activity.setSportType(normalizeSportType(command.sportType()));
        activity.setElapsedTimeSeconds(command.elapsedTimeSeconds());
        activity.setMovingTimeSeconds(command.movingTimeSeconds());
        activity.setTotalDistanceMeters(metrics.distanceMeters());
        activity.setAveragePaceSecondsPerKm(metrics.averagePaceSecondsPerKm());
        activity.setElevationGainMeters(metrics.elevationGainMeters());
        activity.setRoutePolyline(polylineEncoder.encode(route));
        activity = activityRepository.save(activity);

        List<ActivityGpsPoint> entities = new ArrayList<>(command.points().size());
        for (GpsPointCommand point : command.points()) {
            ActivityGpsPoint entity = new ActivityGpsPoint();
            entity.setActivity(activity);
            entity.setLatitude(point.latitude());
            entity.setLongitude(point.longitude());
            entity.setElevation(point.elevation());
            entity.setSpeedMs(point.speedMs());
            entity.setHeartRate(point.heartRate());
            entity.setTimestamp(point.timestamp());
            entity.setLocation(GEOMETRY_FACTORY.createPoint(
                    new Coordinate(point.longitude(), point.latitude())));
            entities.add(entity);
        }
        gpsPointRepository.saveAll(entities);

        if (shoe != null) {
            BigDecimal distanceKm = BigDecimal.valueOf(metrics.distanceMeters())
                    .divide(BigDecimal.valueOf(1_000), 3, RoundingMode.HALF_UP);
            shoe.setAccumulatedDistanceKm(shoe.getAccumulatedDistanceKm().add(distanceKm));
        }
        return activity;
    }

    @Transactional(readOnly = true)
    public ActivityDetails getDetails(UUID activityId) {
        Activity activity = activityRepository.findDetailsById(activityId)
                .orElseThrow(() -> new ResourceNotFoundException("Atividade não encontrada"));
        List<ActivityGpsPoint> points = gpsPointRepository
                .findByActivityIdOrderByTimestampAsc(activityId);
        List<GeoCalculationService.GeoPoint> route = points.stream()
                .map(point -> new GeoCalculationService.GeoPoint(point.getLatitude(), point.getLongitude(),
                        point.getElevation(), point.getTimestamp()))
                .toList();
        List<GeoCalculationService.Split> splits = route.size() < 2 ? List.of()
                : geoCalculationService.calculate(route, activity.getMovingTimeSeconds()).splits();
        return new ActivityDetails(activity, splits);
    }

    private void validate(CreateActivityCommand command) {
        if (command.movingTimeSeconds() > command.elapsedTimeSeconds()) {
            throw new IllegalArgumentException("O tempo em movimento não pode superar o tempo total");
        }
        Instant previous = null;
        for (GpsPointCommand point : command.points()) {
            if (previous != null && point.timestamp().isBefore(previous)) {
                throw new IllegalArgumentException("Os pontos GPS devem estar em ordem cronológica");
            }
            previous = point.timestamp();
        }
    }

    private String normalizeSportType(String sportType) {
        String normalized = sportType == null || sportType.isBlank()
                ? "RUNNING" : sportType.trim().toUpperCase();
        if (!List.of("RUNNING", "CYCLING", "WALKING", "HIKING").contains(normalized)) {
            throw new IllegalArgumentException("Modalidade inválida");
        }
        return normalized;
    }

    public record CreateActivityCommand(String title, String description, String sportType, UUID shoeId,
                                        int elapsedTimeSeconds, int movingTimeSeconds,
                                        List<GpsPointCommand> points) {
    }

    public record GpsPointCommand(double latitude, double longitude, Double elevation,
                                  Double speedMs, Integer heartRate, Instant timestamp) {
    }

    public record ActivityDetails(Activity activity, List<GeoCalculationService.Split> splits) {
    }
}
