package com.sellingticket.util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {
    
    // Define the BCrypt workload to use when generating password hashes. 10-31 is a valid value.
    private static final int DR = 12;

    public static String hashPassword(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt(DR));
    }

    public static boolean checkPassword(String password, String hashed) {
        if (hashed == null || hashed.isEmpty()) {
            return false;
        }
        try {
            return BCrypt.checkpw(password, hashed);
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}
