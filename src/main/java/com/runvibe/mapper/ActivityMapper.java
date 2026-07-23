package com.runvibe.mapper;

import com.runvibe.dto.activity.ActivityResponse;
import com.runvibe.dto.activity.CreateActivityRequest;
import com.runvibe.dto.activity.SplitResponse;
import com.runvibe.entity.Activity;
import com.runvibe.entity.Shoe;
import com.runvibe.service.ActivityService;
import com.runvibe.service.GeoCalculationService;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class ActivityMapper {

    public ActivityService.CreateActivityCommand toCommand(CreateActivityRequest request) {
        List<ActivityService.GpsPointCommand> points = request.points().stream()
                .map(point -> new ActivityService.GpsPointCommand(point.latitude(), point.longitude(),
                        point.elevation(), point.speedMs(), point.heartRate(), point.timestamp()))
                .toList();
        return new ActivityService.CreateActivityCommand(request.title(), request.description(),
                request.shoeId(), request.elapsedTimeSeconds(), request.movingTimeSeconds(), points);
    }

    public ActivityResponse toResponse(Activity activity) {
        return toResponse(activity, List.of());
    }

    public ActivityResponse toResponse(Activity activity, List<GeoCalculationService.Split> splits) {
        Shoe shoe = activity.getShoe();
        List<SplitResponse> splitResponses = splits.stream()
                .map(split -> new SplitResponse(split.kilometer(), split.distanceMeters(),
                        split.durationSeconds(), split.distanceMeters() == 0 ? 0
                        : (int) Math.round(split.durationSeconds() / (split.distanceMeters() / 1_000))))
                .toList();
        return new ActivityResponse(activity.getId(), activity.getUser().getId(),
                activity.getUser().getName(), activity.getTitle(), activity.getDescription(),
                activity.getTotalDistanceMeters(), activity.getElapsedTimeSeconds(),
                activity.getMovingTimeSeconds(), activity.getAveragePaceSecondsPerKm(),
                activity.getElevationGainMeters(), shoe == null ? null : shoe.getId(),
                shoe == null ? null : shoe.getBrand() + " " + shoe.getModel(),
                activity.getRoutePolyline(), activity.getCreatedAt(), splitResponses);
    }
}
