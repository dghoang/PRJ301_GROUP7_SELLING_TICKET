package com.sellingticket.model;

import java.util.Date;

public class User {
    private int userId;
    private String email;
    private String passwordHash;
    private String fullName;
    private String phone;
    private String gender;
    private Date dateOfBirth;
    private String role;
    private String avatar;
    private boolean isActive;

    // Organizer profile
    private String bio;
    private String website;
    private String socialFacebook;
    private String socialInstagram;

    // Security
    private boolean oauthUser;
    private boolean emailVerified;
    private Date lastLoginAt;
    private String lastLoginIp;

    private Date createdAt;
    private Date updatedAt;

    public User() {}

    public User(int userId, String email, String fullName, String role) {
        this.userId = userId;
        this.email = email;
        this.fullName = fullName;
        this.role = role;
    }

    // Getters and Setters
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public Date getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(Date dateOfBirth) { this.dateOfBirth = dateOfBirth; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public String getWebsite() { return website; }
    public void setWebsite(String website) { this.website = website; }

    public String getSocialFacebook() { return socialFacebook; }
    public void setSocialFacebook(String socialFacebook) { this.socialFacebook = socialFacebook; }

    public String getSocialInstagram() { return socialInstagram; }
    public void setSocialInstagram(String socialInstagram) { this.socialInstagram = socialInstagram; }

    public boolean isOauthUser() { return oauthUser; }
    public void setOauthUser(boolean oauthUser) { this.oauthUser = oauthUser; }

    public boolean isEmailVerified() { return emailVerified; }
    public void setEmailVerified(boolean emailVerified) { this.emailVerified = emailVerified; }

    public Date getLastLoginAt() { return lastLoginAt; }
    public void setLastLoginAt(Date lastLoginAt) { this.lastLoginAt = lastLoginAt; }

    public String getLastLoginIp() { return lastLoginIp; }
    public void setLastLoginIp(String lastLoginIp) { this.lastLoginIp = lastLoginIp; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "User{id=" + userId + ", email='" + email + "', role='" + role + "', name='" + fullName + "'}";
    }
}
