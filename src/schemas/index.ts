import { z } from "zod";

// ==========================================
// COMMON VALIDATION RULES
// ==========================================

const vietnamesePhoneRegex = /^(0|\+84)(3|5|7|8|9)[0-9]{8}$/;
const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$/;

export const phoneSchema = z
  .string()
  .min(1, "Số điện thoại không được để trống")
  .regex(vietnamesePhoneRegex, "Số điện thoại không hợp lệ");

export const emailSchema = z
  .string()
  .min(1, "Email không được để trống")
  .email("Email không hợp lệ")
  .max(255, "Email quá dài");

export const passwordSchema = z
  .string()
  .min(8, "Mật khẩu phải có ít nhất 8 ký tự")
  .regex(
    passwordRegex,
    "Mật khẩu phải có ít nhất 1 chữ hoa, 1 chữ thường và 1 số"
  );

export const nameSchema = z
  .string()
  .min(2, "Tên phải có ít nhất 2 ký tự")
  .max(100, "Tên quá dài")
  .regex(/^[\p{L}\s]+$/u, "Tên chỉ được chứa chữ cái");

// ==========================================
// AUTH SCHEMAS
// ==========================================

export const loginSchema = z.object({
  email: emailSchema,
  password: z.string().min(1, "Mật khẩu không được để trống"),
});

export const registerSchema = z
  .object({
    fullName: nameSchema,
    email: emailSchema,
    phone: phoneSchema,
    password: passwordSchema,
    confirmPassword: z.string().min(1, "Xác nhận mật khẩu không được để trống"),
    dateOfBirth: z.string().optional(),
    gender: z.enum(["male", "female", "other"]).optional(),
    agreeTerms: z.boolean().refine((val) => val === true, {
      message: "Bạn phải đồng ý với điều khoản sử dụng",
    }),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Mật khẩu xác nhận không khớp",
    path: ["confirmPassword"],
  });

export const forgotPasswordSchema = z.object({
  email: emailSchema,
});

export const resetPasswordSchema = z
  .object({
    password: passwordSchema,
    confirmPassword: z.string().min(1, "Xác nhận mật khẩu không được để trống"),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Mật khẩu xác nhận không khớp",
    path: ["confirmPassword"],
  });

export const changePasswordSchema = z
  .object({
    currentPassword: z.string().min(1, "Mật khẩu hiện tại không được để trống"),
    newPassword: passwordSchema,
    confirmPassword: z.string().min(1, "Xác nhận mật khẩu không được để trống"),
  })
  .refine((data) => data.newPassword === data.confirmPassword, {
    message: "Mật khẩu xác nhận không khớp",
    path: ["confirmPassword"],
  });

// ==========================================
// USER PROFILE SCHEMA
// ==========================================

export const profileSchema = z.object({
  fullName: nameSchema,
  phone: phoneSchema,
  dateOfBirth: z.string().optional(),
  gender: z.enum(["male", "female", "other"]).optional(),
});

// ==========================================
// EVENT SCHEMAS
// ==========================================

export const eventBasicInfoSchema = z.object({
  name: z
    .string()
    .min(5, "Tên sự kiện phải có ít nhất 5 ký tự")
    .max(200, "Tên sự kiện quá dài"),
  description: z
    .string()
    .min(50, "Mô tả phải có ít nhất 50 ký tự")
    .max(5000, "Mô tả quá dài"),
  categoryId: z.string().min(1, "Vui lòng chọn thể loại"),
});

export const eventLocationSchema = z
  .object({
    type: z.enum(["online", "offline"]),
    venueName: z.string().optional(),
    address: z.string().optional(),
    city: z.string().optional(),
    district: z.string().optional(),
    ward: z.string().optional(),
    onlineUrl: z.string().url("URL không hợp lệ").optional().or(z.literal("")),
    onlinePlatform: z.string().optional(),
  })
  .refine(
    (data) => {
      if (data.type === "offline") {
        return !!data.venueName && !!data.address && !!data.city;
      }
      return true;
    },
    {
      message: "Vui lòng điền đầy đủ thông tin địa điểm",
      path: ["venueName"],
    }
  )
  .refine(
    (data) => {
      if (data.type === "online") {
        return !!data.onlineUrl;
      }
      return true;
    },
    {
      message: "Vui lòng nhập link tham gia",
      path: ["onlineUrl"],
    }
  );

export const eventScheduleSchema = z.object({
  startTime: z.string().min(1, "Vui lòng chọn thời gian bắt đầu"),
  endTime: z.string().min(1, "Vui lòng chọn thời gian kết thúc"),
  gateOpenTime: z.string().optional(),
});

export const ticketTypeSchema = z.object({
  name: z.string().min(1, "Tên vé không được để trống").max(100, "Tên vé quá dài"),
  description: z.string().max(500, "Mô tả quá dài").optional(),
  price: z.number().min(0, "Giá không được âm"),
  originalPrice: z.number().min(0, "Giá gốc không được âm").optional(),
  quantity: z.number().min(1, "Số lượng phải lớn hơn 0"),
  maxPerOrder: z.number().min(1, "Số lượng tối đa mỗi đơn phải lớn hơn 0"),
  minPerOrder: z.number().min(1, "Số lượng tối thiểu mỗi đơn phải lớn hơn 0"),
  saleStartTime: z.string().min(1, "Vui lòng chọn thời gian bắt đầu bán"),
  saleEndTime: z.string().min(1, "Vui lòng chọn thời gian kết thúc bán"),
});

export const eventPrivacySchema = z.object({
  privacy: z.enum(["public", "private", "unlisted"]),
  accessCode: z.string().optional(),
  customUrl: z
    .string()
    .regex(/^[a-z0-9-]+$/, "URL chỉ được chứa chữ thường, số và dấu gạch ngang")
    .optional()
    .or(z.literal("")),
});

export const organizerInfoSchema = z.object({
  name: z.string().min(2, "Tên tổ chức phải có ít nhất 2 ký tự"),
  logo: z.string().optional(),
  description: z.string().max(1000, "Mô tả quá dài").optional(),
  email: emailSchema,
  phone: phoneSchema.optional(),
});

export const bankingInfoSchema = z.object({
  bankName: z.string().min(1, "Vui lòng chọn ngân hàng"),
  accountNumber: z
    .string()
    .min(6, "Số tài khoản không hợp lệ")
    .max(20, "Số tài khoản quá dài")
    .regex(/^\d+$/, "Số tài khoản chỉ được chứa số"),
  accountHolder: z.string().min(2, "Tên chủ tài khoản không hợp lệ"),
  branch: z.string().optional(),
});

// ==========================================
// ORDER SCHEMAS
// ==========================================

export const customerInfoSchema = z.object({
  fullName: nameSchema,
  email: emailSchema,
  phone: phoneSchema,
});

export const shippingAddressSchema = z.object({
  recipientName: nameSchema,
  phone: phoneSchema,
  address: z.string().min(5, "Địa chỉ không hợp lệ").max(255, "Địa chỉ quá dài"),
  city: z.string().min(1, "Vui lòng chọn tỉnh/thành phố"),
  district: z.string().min(1, "Vui lòng chọn quận/huyện"),
  ward: z.string().min(1, "Vui lòng chọn phường/xã"),
  notes: z.string().max(500, "Ghi chú quá dài").optional(),
});

export const checkoutSchema = z
  .object({
    deliveryType: z.enum(["electronic", "physical"]),
    paymentMethod: z.enum(["bank_transfer", "credit_card", "momo", "zalopay", "vnpay"]),
    customerInfo: customerInfoSchema,
    shippingAddress: shippingAddressSchema.optional(),
    voucherCode: z.string().optional(),
    agreeTerms: z.boolean().refine((val) => val === true, {
      message: "Bạn phải đồng ý với điều khoản mua vé",
    }),
  })
  .refine(
    (data) => {
      if (data.deliveryType === "physical") {
        return !!data.shippingAddress;
      }
      return true;
    },
    {
      message: "Vui lòng điền địa chỉ giao hàng",
      path: ["shippingAddress"],
    }
  );

// ==========================================
// VOUCHER SCHEMAS
// ==========================================

export const voucherSchema = z
  .object({
    code: z
      .string()
      .min(3, "Mã giảm giá phải có ít nhất 3 ký tự")
      .max(20, "Mã giảm giá quá dài")
      .regex(/^[A-Z0-9]+$/, "Mã giảm giá chỉ được chứa chữ in hoa và số"),
    name: z.string().min(2, "Tên không được để trống").max(100, "Tên quá dài"),
    description: z.string().max(500, "Mô tả quá dài").optional(),
    type: z.enum(["percentage", "fixed_amount"]),
    value: z.number().min(0, "Giá trị không được âm"),
    minOrderAmount: z.number().min(0, "Giá trị không được âm").optional(),
    maxDiscount: z.number().min(0, "Giá trị không được âm").optional(),
    quantity: z.number().min(1, "Số lượng phải lớn hơn 0").optional(),
    maxUsagePerUser: z.number().min(1, "Số lần sử dụng phải lớn hơn 0"),
    startTime: z.string().min(1, "Vui lòng chọn thời gian bắt đầu"),
    endTime: z.string().min(1, "Vui lòng chọn thời gian kết thúc"),
  })
  .refine(
    (data) => {
      if (data.type === "percentage" && data.value > 100) {
        return false;
      }
      return true;
    },
    {
      message: "Phần trăm giảm giá không được vượt quá 100%",
      path: ["value"],
    }
  );

// ==========================================
// TEAM SCHEMAS
// ==========================================

export const teamInviteSchema = z.object({
  email: emailSchema,
  role: z.enum(["admin", "manager", "check_in", "viewer"]),
  eventIds: z.array(z.string()).optional(),
});

// ==========================================
// ADMIN SCHEMAS
// ==========================================

export const eventRejectSchema = z.object({
  reason: z.string().min(10, "Lý do từ chối phải có ít nhất 10 ký tự").max(500, "Lý do quá dài"),
});

export const userBanSchema = z.object({
  reason: z.string().min(10, "Lý do khóa phải có ít nhất 10 ký tự").max(500, "Lý do quá dài"),
});

export const shippingProviderSchema = z.object({
  name: z.string().min(2, "Tên không hợp lệ").max(100, "Tên quá dài"),
  code: z
    .string()
    .min(2, "Mã không hợp lệ")
    .max(10, "Mã quá dài")
    .regex(/^[A-Z]+$/, "Mã chỉ được chứa chữ in hoa"),
  baseFee: z.number().min(0, "Phí không được âm"),
  feePerKm: z.number().min(0, "Phí không được âm"),
  estimatedDays: z.string().min(1, "Vui lòng nhập thời gian giao hàng"),
  regions: z.array(z.string()).min(1, "Vui lòng chọn ít nhất 1 khu vực"),
});

// ==========================================
// CHECK-IN SCHEMA
// ==========================================

export const checkInSchema = z.object({
  ticketCode: z.string().min(1, "Mã vé không được để trống"),
  eventId: z.string().min(1, "ID sự kiện không hợp lệ"),
  scheduleId: z.string().optional(),
});

// ==========================================
// TYPE EXPORTS
// ==========================================

export type LoginFormData = z.infer<typeof loginSchema>;
export type RegisterFormData = z.infer<typeof registerSchema>;
export type ProfileFormData = z.infer<typeof profileSchema>;
export type EventBasicInfoFormData = z.infer<typeof eventBasicInfoSchema>;
export type EventLocationFormData = z.infer<typeof eventLocationSchema>;
export type TicketTypeFormData = z.infer<typeof ticketTypeSchema>;
export type BankingInfoFormData = z.infer<typeof bankingInfoSchema>;
export type CheckoutFormData = z.infer<typeof checkoutSchema>;
export type VoucherFormData = z.infer<typeof voucherSchema>;
export type TeamInviteFormData = z.infer<typeof teamInviteSchema>;
