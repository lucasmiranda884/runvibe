package com.runvibe.controller;

import com.runvibe.dto.social.ToggleResponse;
import com.runvibe.security.UserPrincipal;
import com.runvibe.service.SocialService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final SocialService socialService;

    @PostMapping("/{id}/follow")
    public ToggleResponse toggleFollow(@PathVariable UUID id,
                                       @AuthenticationPrincipal UserPrincipal principal) {
        return new ToggleResponse(socialService.toggleFollow(principal.id(), id).active());
    }
}
