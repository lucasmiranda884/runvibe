package com.runvibe.controller;

import com.runvibe.dto.activity.ActivityResponse;
import com.runvibe.dto.activity.CreateActivityRequest;
import com.runvibe.dto.social.ToggleResponse;
import com.runvibe.entity.Activity;
import com.runvibe.mapper.ActivityMapper;
import com.runvibe.security.UserPrincipal;
import com.runvibe.service.ActivityService;
import com.runvibe.service.SocialService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/activities")
@RequiredArgsConstructor
public class ActivityController {

    private final ActivityService activityService;
    private final SocialService socialService;
    private final ActivityMapper activityMapper;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ActivityResponse create(@AuthenticationPrincipal UserPrincipal principal,
                                   @Valid @RequestBody CreateActivityRequest request) {
        Activity activity = activityService.create(principal.id(), activityMapper.toCommand(request));
        return activityMapper.toResponse(activity);
    }

    @GetMapping("/{id}")
    public ActivityResponse details(@PathVariable UUID id) {
        ActivityService.ActivityDetails details = activityService.getDetails(id);
        return activityMapper.toResponse(details.activity(), details.splits());
    }

    @PostMapping("/{id}/kudos")
    public ToggleResponse toggleKudos(@PathVariable UUID id,
                                      @AuthenticationPrincipal UserPrincipal principal) {
        return new ToggleResponse(socialService.toggleKudos(id, principal.id()).active());
    }
}
