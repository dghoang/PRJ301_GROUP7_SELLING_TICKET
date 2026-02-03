import { API_URL, REQUEST_TIMEOUT, getDefaultHeaders, getAuthHeader } from "@/config/api.config";
import { STORAGE_KEYS } from "@/config/constants";
import type { ApiResponse, ApiError } from "@/types";

// ==========================================
// HTTP CLIENT
// ==========================================

class HttpClient {
  private baseUrl: string;
  private timeout: number;

  constructor(baseUrl: string = API_URL, timeout: number = REQUEST_TIMEOUT) {
    this.baseUrl = baseUrl;
    this.timeout = timeout;
  }

  private getToken(): string | null {
    return localStorage.getItem(STORAGE_KEYS.ACCESS_TOKEN);
  }

  private async handleResponse<T>(response: Response): Promise<ApiResponse<T>> {
    const contentType = response.headers.get("content-type");
    
    if (!contentType || !contentType.includes("application/json")) {
      if (!response.ok) {
        return {
          success: false,
          error: {
            code: "NETWORK_ERROR",
            message: "Lỗi kết nối server",
          },
        };
      }
      return { success: true };
    }

    const data = await response.json();

    if (!response.ok) {
      return {
        success: false,
        error: data as ApiError,
      };
    }

    return {
      success: true,
      data: data as T,
    };
  }

  private async request<T>(
    method: string,
    endpoint: string,
    body?: unknown,
    customHeaders?: Record<string, string>
  ): Promise<ApiResponse<T>> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout);

    try {
      const headers: Record<string, string> = {
        ...getDefaultHeaders(),
        ...customHeaders,
      };

      const token = this.getToken();
      if (token) {
        Object.assign(headers, getAuthHeader(token));
      }

      const config: RequestInit = {
        method,
        headers,
        signal: controller.signal,
      };

      if (body && method !== "GET") {
        config.body = JSON.stringify(body);
      }

      const response = await fetch(`${this.baseUrl}${endpoint}`, config);
      
      // Handle 401 Unauthorized - Token expired
      if (response.status === 401) {
        // Try to refresh token
        const refreshed = await this.refreshToken();
        if (refreshed) {
          // Retry the request with new token
          const newHeaders = { ...headers, ...getAuthHeader(this.getToken()!) };
          const retryResponse = await fetch(`${this.baseUrl}${endpoint}`, {
            ...config,
            headers: newHeaders,
          });
          return this.handleResponse<T>(retryResponse);
        } else {
          // Refresh failed, clear auth
          this.clearAuth();
          window.location.href = "/login";
          return {
            success: false,
            error: { code: "UNAUTHORIZED", message: "Phiên đăng nhập hết hạn" },
          };
        }
      }

      return this.handleResponse<T>(response);
    } catch (error) {
      if (error instanceof Error && error.name === "AbortError") {
        return {
          success: false,
          error: { code: "TIMEOUT", message: "Yêu cầu quá thời gian chờ" },
        };
      }
      return {
        success: false,
        error: { code: "NETWORK_ERROR", message: "Lỗi kết nối mạng" },
      };
    } finally {
      clearTimeout(timeoutId);
    }
  }

  private async refreshToken(): Promise<boolean> {
    const refreshToken = localStorage.getItem(STORAGE_KEYS.REFRESH_TOKEN);
    if (!refreshToken) return false;

    try {
      const response = await fetch(`${this.baseUrl}/auth/refresh`, {
        method: "POST",
        headers: getDefaultHeaders(),
        body: JSON.stringify({ refreshToken }),
      });

      if (response.ok) {
        const data = await response.json();
        localStorage.setItem(STORAGE_KEYS.ACCESS_TOKEN, data.accessToken);
        if (data.refreshToken) {
          localStorage.setItem(STORAGE_KEYS.REFRESH_TOKEN, data.refreshToken);
        }
        return true;
      }
      return false;
    } catch {
      return false;
    }
  }

  private clearAuth(): void {
    localStorage.removeItem(STORAGE_KEYS.ACCESS_TOKEN);
    localStorage.removeItem(STORAGE_KEYS.REFRESH_TOKEN);
    localStorage.removeItem(STORAGE_KEYS.USER);
  }

  // HTTP Methods
  async get<T>(endpoint: string, params?: Record<string, string>): Promise<ApiResponse<T>> {
    const queryString = params ? "?" + new URLSearchParams(params).toString() : "";
    return this.request<T>("GET", `${endpoint}${queryString}`);
  }

  async post<T>(endpoint: string, body?: unknown): Promise<ApiResponse<T>> {
    return this.request<T>("POST", endpoint, body);
  }

  async put<T>(endpoint: string, body?: unknown): Promise<ApiResponse<T>> {
    return this.request<T>("PUT", endpoint, body);
  }

  async patch<T>(endpoint: string, body?: unknown): Promise<ApiResponse<T>> {
    return this.request<T>("PATCH", endpoint, body);
  }

  async delete<T>(endpoint: string): Promise<ApiResponse<T>> {
    return this.request<T>("DELETE", endpoint);
  }

  // File upload
  async uploadFile<T>(endpoint: string, file: File, fieldName: string = "file"): Promise<ApiResponse<T>> {
    const formData = new FormData();
    formData.append(fieldName, file);

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout * 2); // Double timeout for uploads

    try {
      const headers: Record<string, string> = {};
      const token = this.getToken();
      if (token) {
        Object.assign(headers, getAuthHeader(token));
      }

      const response = await fetch(`${this.baseUrl}${endpoint}`, {
        method: "POST",
        headers,
        body: formData,
        signal: controller.signal,
      });

      return this.handleResponse<T>(response);
    } catch (error) {
      return {
        success: false,
        error: { code: "UPLOAD_ERROR", message: "Lỗi tải file lên" },
      };
    } finally {
      clearTimeout(timeoutId);
    }
  }

  async uploadMultipleFiles<T>(
    endpoint: string,
    files: File[],
    fieldName: string = "files"
  ): Promise<ApiResponse<T>> {
    const formData = new FormData();
    files.forEach((file) => formData.append(fieldName, file));

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout * 3);

    try {
      const headers: Record<string, string> = {};
      const token = this.getToken();
      if (token) {
        Object.assign(headers, getAuthHeader(token));
      }

      const response = await fetch(`${this.baseUrl}${endpoint}`, {
        method: "POST",
        headers,
        body: formData,
        signal: controller.signal,
      });

      return this.handleResponse<T>(response);
    } catch (error) {
      return {
        success: false,
        error: { code: "UPLOAD_ERROR", message: "Lỗi tải files lên" },
      };
    } finally {
      clearTimeout(timeoutId);
    }
  }
}

// Export singleton instance
export const httpClient = new HttpClient();

// Export class for custom instances
export { HttpClient };
