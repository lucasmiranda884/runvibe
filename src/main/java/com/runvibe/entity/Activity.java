package com.runvibe.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "activities")
public class Activity {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 160)
    private String title;

    @Column(length = 2000)
    private String description;

    @Column(name = "total_distance_meters", nullable = false)
    private Double totalDistanceMeters;

    @Column(name = "elapsed_time_seconds", nullable = false)
    private Integer elapsedTimeSeconds;

    @Column(name = "moving_time_seconds", nullable = false)
    private Integer movingTimeSeconds;

    @Column(name = "average_pace_seconds_per_km", nullable = false)
    private Integer averagePaceSecondsPerKm;

    @Column(name = "elevation_gain_meters", nullable = false)
    private Double elevationGainMeters;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shoe_id")
    private Shoe shoe;

    @Column(name = "route_polyline", columnDefinition = "text")
    private String routePolyline;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @OneToMany(mappedBy = "activity")
    private List<ActivityGpsPoint> gpsPoints = new ArrayList<>();

    @PrePersist
    void prePersist() {
        if (createdAt == null) createdAt = Instant.now();
    }
}
