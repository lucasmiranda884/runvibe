package com.runvibe.service;

import com.runvibe.dto.auth.AuthResponse;
import com.runvibe.dto.auth.LoginRequest;
import com.runvibe.dto.auth.RegisterRequest;
import com.runvibe.entity.User;
import com.runvibe.security.JwtService;
import com.runvibe.security.UserPrincipal;
import com.runvibe.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthenticationService {

    private final RegistrationService registrationService;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final UserRepository userRepository;

    public AuthResponse register(RegisterRequest request) {
        User user = registrationService.register(request.name(), request.email(), request.password());
        return response(UserPrincipal.from(user), user.getName());
    }

    public AuthResponse login(LoginRequest request) {
        var authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email(), request.password()));
        UserPrincipal principal = (UserPrincipal) authentication.getPrincipal();
        String name = userRepository.findById(principal.id()).map(User::getName).orElse(null);
        return response(principal, name);
    }

    private AuthResponse response(UserPrincipal principal, String name) {
        return new AuthResponse(jwtService.generate(principal), "Bearer",
                jwtService.expirationSeconds(), principal.id(), name, principal.email());
    }
}
