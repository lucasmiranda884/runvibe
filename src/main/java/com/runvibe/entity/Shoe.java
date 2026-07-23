package com.runvibe.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "shoes")
public class Shoe {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 100)
    private String brand;

    @Column(nullable = false, length = 120)
    private String model;

    @Column(name = "max_distance_km", nullable = false, precision = 10, scale = 2)
    private BigDecimal maxDistanceKm;

    @Column(name = "accumulated_distance_km", nullable = false, precision = 12, scale = 3)
    private BigDecimal accumulatedDistanceKm = BigDecimal.ZERO;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;
}
