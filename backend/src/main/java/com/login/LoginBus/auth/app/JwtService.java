package com.login.LoginBus.auth.app;

import com.login.LoginBus.auth.domain.TokenType;
import com.login.LoginBus.accounts.infra.UserJpaEntity;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.*;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class JwtService {

    private final JwtEncoder jwtEncoder;
    private final JwtDecoder jwtDecoder;

    @Value("${app.jwt.issuer}")
    private String issuer;

    @Value("${app.jwt.expiry-seconds}")
    private long accessExpirySeconds;

    private final long refreshExpirySeconds = 7L * 24L * 3600L;

    public JwtService(JwtEncoder jwtEncoder, JwtDecoder jwtDecoder) {
        this.jwtEncoder = jwtEncoder;
        this.jwtDecoder = jwtDecoder;
    }

    public TokenPair issueTokens(UserJpaEntity user) {
        Instant now = Instant.now();
        Instant accessExp = now.plusSeconds(accessExpirySeconds);
        Instant refreshExp = now.plusSeconds(refreshExpirySeconds);

        List<String> roles = List.of(user.getRole().name());

        String access = encode(user.getId(), user.getEmail(), roles, TokenType.ACCESS, now, accessExp);
        String refresh = encode(user.getId(), user.getEmail(), roles, TokenType.REFRESH, now, refreshExp);

        return new TokenPair(access, accessExp, refresh, refreshExp, user.getId(), roles);
    }

    public TokenPair refresh(String refreshToken) {
        Jwt jwt = jwtDecoder.decode(refreshToken);

        String tokenType = jwt.getClaimAsString("token_type");
        if (!TokenType.REFRESH.name().equals(tokenType)) {
            throw new IllegalArgumentException("Invalid refresh token.");
        }

        Long userId = jwt.getClaim("user_id");
        String email = jwt.getClaimAsString("email");
        List<String> roles = jwt.getClaimAsStringList("roles");

        if (userId == null || email == null || roles == null || roles.isEmpty()) {
            throw new IllegalArgumentException("Invalid refresh token.");
        }

        Instant now = Instant.now();
        Instant accessExp = now.plusSeconds(accessExpirySeconds);
        Instant refreshExp = now.plusSeconds(refreshExpirySeconds);

        String access = encode(userId, email, roles, TokenType.ACCESS, now, accessExp);
        String refresh = encode(userId, email, roles, TokenType.REFRESH, now, refreshExp);

        return new TokenPair(access, accessExp, refresh, refreshExp, userId, roles);
    }

    private String encode(Long userId, String email, List<String> roles, TokenType type,
                          Instant issuedAt, Instant expiresAt) {
        JwsHeader header = JwsHeader.with(MacAlgorithm.HS256)
                .keyId("login-bus-hs256")
                .build();

        JwtClaimsSet claims = JwtClaimsSet.builder()
                .issuer(issuer)
                .issuedAt(issuedAt)
                .expiresAt(expiresAt)
                .subject(String.valueOf(userId))
                .id(UUID.randomUUID().toString())
                .claim("token_type", type.name())
                .claim("user_id", userId)
                .claim("email", email)
                .claim("roles", roles)
                .build();

        return jwtEncoder.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
    }

    public record TokenPair(
            String accessToken,
            Instant accessExpiresAt,
            String refreshToken,
            Instant refreshExpiresAt,
            Long userId,
            List<String> roles
    ) {}
}
