import { httpClient } from "./http.service";
import { API_ENDPOINTS } from "@/config/api.config";
import { STORAGE_KEYS } from "@/config/constants";
import type {
  User,
  AuthResponse,
  LoginRequest,
  RegisterRequest,
  ApiResponse,
} from "@/types";

// ==========================================
// AUTH SERVICE
// ==========================================

class AuthService {
  async login(credentials: LoginRequest): Promise<ApiResponse<AuthResponse>> {
    const response = await httpClient.post<AuthResponse>(
      API_ENDPOINTS.AUTH.LOGIN,
      credentials
    );

    if (response.success && response.data) {
      this.setAuthData(response.data);
    }

    return response;
  }

  async register(data: RegisterRequest): Promise<ApiResponse<AuthResponse>> {
    const response = await httpClient.post<AuthResponse>(
      API_ENDPOINTS.AUTH.REGISTER,
      data
    );

    if (response.success && response.data) {
      this.setAuthData(response.data);
    }

    return response;
  }

  async logout(): Promise<void> {
    try {
      await httpClient.post(API_ENDPOINTS.AUTH.LOGOUT);
    } finally {
      this.clearAuthData();
    }
  }

  async getCurrentUser(): Promise<ApiResponse<User>> {
    return httpClient.get<User>(API_ENDPOINTS.AUTH.ME);
  }

  async forgotPassword(email: string): Promise<ApiResponse<void>> {
    return httpClient.post(API_ENDPOINTS.AUTH.FORGOT_PASSWORD, { email });
  }

  async resetPassword(token: string, password: string): Promise<ApiResponse<void>> {
    return httpClient.post(API_ENDPOINTS.AUTH.RESET_PASSWORD, { token, password });
  }

  async verifyEmail(token: string): Promise<ApiResponse<void>> {
    return httpClient.post(API_ENDPOINTS.AUTH.VERIFY_EMAIL, { token });
  }

  async resendVerificationEmail(): Promise<ApiResponse<void>> {
    return httpClient.post(API_ENDPOINTS.AUTH.RESEND_VERIFICATION);
  }

  async changePassword(currentPassword: string, newPassword: string): Promise<ApiResponse<void>> {
    return httpClient.post(API_ENDPOINTS.USERS.CHANGE_PASSWORD, {
      currentPassword,
      newPassword,
    });
  }

  async updateProfile(data: Partial<User>): Promise<ApiResponse<User>> {
    return httpClient.put<User>(API_ENDPOINTS.USERS.PROFILE, data);
  }

  async uploadAvatar(file: File): Promise<ApiResponse<{ url: string }>> {
    return httpClient.uploadFile<{ url: string }>(
      API_ENDPOINTS.USERS.UPLOAD_AVATAR,
      file,
      "avatar"
    );
  }

  // Helper methods
  private setAuthData(data: AuthResponse): void {
    localStorage.setItem(STORAGE_KEYS.ACCESS_TOKEN, data.accessToken);
    localStorage.setItem(STORAGE_KEYS.REFRESH_TOKEN, data.refreshToken);
    localStorage.setItem(STORAGE_KEYS.USER, JSON.stringify(data.user));
  }

  private clearAuthData(): void {
    localStorage.removeItem(STORAGE_KEYS.ACCESS_TOKEN);
    localStorage.removeItem(STORAGE_KEYS.REFRESH_TOKEN);
    localStorage.removeItem(STORAGE_KEYS.USER);
  }

  getStoredUser(): User | null {
    const userStr = localStorage.getItem(STORAGE_KEYS.USER);
    return userStr ? JSON.parse(userStr) : null;
  }

  isAuthenticated(): boolean {
    return !!localStorage.getItem(STORAGE_KEYS.ACCESS_TOKEN);
  }

  getAccessToken(): string | null {
    return localStorage.getItem(STORAGE_KEYS.ACCESS_TOKEN);
  }
}

export const authService = new AuthService();
