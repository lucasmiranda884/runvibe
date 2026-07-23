package com.runvibe.service;

import com.runvibe.entity.Activity;
import com.runvibe.repository.ActivityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FeedService {

    private final ActivityRepository activityRepository;

    @Transactional(readOnly = true)
    public Page<Activity> getFeed(UUID viewerId, Pageable pageable) {
        return activityRepository.findFeed(viewerId, pageable);
    }
}
