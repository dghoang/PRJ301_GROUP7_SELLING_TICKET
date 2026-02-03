import { httpClient } from "./http.service";
import { API_ENDPOINTS } from "@/config/api.config";
import type { ShippingProvider, ApiResponse } from "@/types";

// ==========================================
// SHIPPING SERVICE
// ==========================================

class ShippingService {
  // Get available shipping providers
  async getProviders(): Promise<ApiResponse<ShippingProvider[]>> {
    return httpClient.get<ShippingProvider[]>(API_ENDPOINTS.SHIPPING.PROVIDERS);
  }

  // Calculate shipping fee
  async calculateFee(
    providerId: string,
    fromCity: string,
    toCity: string,
    toDistrict: string
  ): Promise<ApiResponse<{
    fee: number;
    estimatedDays: string;
  }>> {
    return httpClient.post(API_ENDPOINTS.SHIPPING.CALCULATE_FEE, {
      providerId,
      fromCity,
      toCity,
      toDistrict,
    });
  }

  // Track shipment
  async trackShipment(trackingNumber: string): Promise<ApiResponse<{
    status: string;
    history: Array<{
      timestamp: string;
      status: string;
      location: string;
      description: string;
    }>;
  }>> {
    return httpClient.get(API_ENDPOINTS.SHIPPING.TRACK(trackingNumber));
  }
}

// ==========================================
// UPLOAD SERVICE
// ==========================================

class UploadService {
  async uploadImage(file: File): Promise<ApiResponse<{ url: string }>> {
    return httpClient.uploadFile<{ url: string }>(
      API_ENDPOINTS.UPLOAD.IMAGE,
      file,
      "image"
    );
  }

  async uploadImages(files: File[]): Promise<ApiResponse<{ urls: string[] }>> {
    return httpClient.uploadMultipleFiles<{ urls: string[] }>(
      API_ENDPOINTS.UPLOAD.IMAGES,
      files,
      "images"
    );
  }

  async uploadFile(file: File): Promise<ApiResponse<{ url: string; filename: string }>> {
    return httpClient.uploadFile<{ url: string; filename: string }>(
      API_ENDPOINTS.UPLOAD.FILE,
      file,
      "file"
    );
  }
}

// ==========================================
// PAYMENT SERVICE
// ==========================================

class PaymentService {
  async createPayment(
    orderId: string,
    paymentMethod: string,
    returnUrl: string
  ): Promise<ApiResponse<{
    paymentUrl: string;
    transactionId: string;
  }>> {
    return httpClient.post(API_ENDPOINTS.PAYMENT.CREATE, {
      orderId,
      paymentMethod,
      returnUrl,
    });
  }

  async getPaymentStatus(orderId: string): Promise<ApiResponse<{
    status: string;
    paidAt?: string;
    transactionId?: string;
  }>> {
    return httpClient.get(API_ENDPOINTS.PAYMENT.STATUS(orderId));
  }
}

export const shippingService = new ShippingService();
export const uploadService = new UploadService();
export const paymentService = new PaymentService();
