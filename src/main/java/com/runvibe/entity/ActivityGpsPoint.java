package com.runvibe.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.locationtech.jts.geom.Point;

import java.time.Instant;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "activity_gps_points")
public class ActivityGpsPoint {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "gps_point_sequence")
    @SequenceGenerator(name = "gps_point_sequence", sequenceName = "activity_gps_points_seq",
            allocationSize = 500)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "activity_id", nullable = false)
    private Activity activity;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    private Double elevation;

    @Column(name = "speed_ms")
    private Double speedMs;

    @Column(name = "heart_rate")
    private Integer heartRate;

    @Column(nullable = false)
    private Instant timestamp;

    @Column(nullable = false, columnDefinition = "geometry(Point,4326)")
    private Point location;
}
