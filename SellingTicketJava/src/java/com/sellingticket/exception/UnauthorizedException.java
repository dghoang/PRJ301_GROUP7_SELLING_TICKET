package com.sellingticket.exception;

/**
 * Thrown when a user attempts an action without proper authentication or authorization.
 */
public class UnauthorizedException extends RuntimeException {

    private final String requiredRole;

    public UnauthorizedException() {
        super("Authentication required");
        this.requiredRole = null;
    }

    public UnauthorizedException(String requiredRole) {
        super("Access denied. Required role: " + requiredRole);
        this.requiredRole = requiredRole;
    }

    public String getRequiredRole() {
        return requiredRole;
    }
}
