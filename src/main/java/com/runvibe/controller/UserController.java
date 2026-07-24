package com.runvibe.controller;

import com.runvibe.dto.social.ToggleResponse;
import com.runvibe.dto.user.UpdateUserProfileRequest;
import com.runvibe.dto.user.UserProfileResponse;
import com.runvibe.security.UserPrincipal;
import com.runvibe.service.SocialService;
import com.runvibe.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;
import java.util.List;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final SocialService socialService;
    private final UserService userService;

    @GetMapping("/me")
    public UserProfileResponse me(@AuthenticationPrincipal UserPrincipal principal) {
        return userService.me(principal.id());
    }

    @PatchMapping("/me")
    public UserProfileResponse update(@AuthenticationPrincipal UserPrincipal principal,
                                      @Valid @RequestBody UpdateUserProfileRequest request) {
        return userService.update(principal.id(), request);
    }

    @GetMapping("/search")
    public List<UserProfileResponse> search(@RequestParam String query,
                                            @AuthenticationPrincipal UserPrincipal principal) {
        return userService.search(principal.id(), query);
    }

    @PostMapping("/{id}/follow")
    public ToggleResponse toggleFollow(@PathVariable UUID id,
                                       @AuthenticationPrincipal UserPrincipal principal) {
        return new ToggleResponse(socialService.toggleFollow(principal.id(), id).active());
    }
}
