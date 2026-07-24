package com.runvibe.service;

import com.runvibe.dto.user.UpdateUserProfileRequest;
import com.runvibe.dto.user.UserProfileResponse;
import com.runvibe.entity.User;
import com.runvibe.entity.UserFollowId;
import com.runvibe.exception.ResourceNotFoundException;
import com.runvibe.repository.UserFollowRepository;
import com.runvibe.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final UserFollowRepository followRepository;

    @Transactional(readOnly = true)
    public UserProfileResponse me(UUID userId) {
        return response(find(userId), userId);
    }

    @Transactional
    public UserProfileResponse update(UUID userId, UpdateUserProfileRequest request) {
        User user = find(userId);
        user.setName(request.name().trim());
        user.setBio(blankToNull(request.bio()));
        user.setProfilePictureUrl(blankToNull(request.profilePictureUrl()));
        return response(user, userId);
    }

    @Transactional(readOnly = true)
    public List<UserProfileResponse> search(UUID currentUserId, String query) {
        String normalized = query == null ? "" : query.trim();
        if (normalized.length() < 2) return List.of();
        return userRepository.search(normalized, currentUserId).stream()
                .limit(20)
                .map(user -> response(user, currentUserId))
                .toList();
    }

    private User find(UUID id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Usuário não encontrado"));
    }

    private UserProfileResponse response(User user, UUID currentUserId) {
        return new UserProfileResponse(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getBio(),
                user.getProfilePictureUrl(),
                user.getCreatedAt(),
                followRepository.countFollowers(user.getId()),
                followRepository.countFollowing(user.getId()),
                !user.getId().equals(currentUserId)
                        && followRepository.existsById(
                        new UserFollowId(currentUserId, user.getId()))
        );
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
