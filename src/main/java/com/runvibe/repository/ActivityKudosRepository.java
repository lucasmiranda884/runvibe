package com.runvibe.repository;

import com.runvibe.entity.ActivityKudos;
import com.runvibe.entity.ActivityKudosId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ActivityKudosRepository extends JpaRepository<ActivityKudos, ActivityKudosId> {
    long countByActivityId(UUID activityId);
}
