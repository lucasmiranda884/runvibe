package com.runvibe.controller;

import com.runvibe.dto.activity.ActivityResponse;
import com.runvibe.mapper.ActivityMapper;
import com.runvibe.security.UserPrincipal;
import com.runvibe.service.FeedService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/feed")
@RequiredArgsConstructor
public class FeedController {

    private final FeedService feedService;
    private final ActivityMapper activityMapper;

    @GetMapping
    public Page<ActivityResponse> feed(@AuthenticationPrincipal UserPrincipal principal,
                                       @PageableDefault(size = 20, sort = "createdAt",
                                               direction = org.springframework.data.domain.Sort.Direction.DESC)
                                       Pageable pageable) {
        return feedService.getFeed(principal.id(), pageable).map(activityMapper::toResponse);
    }
}
