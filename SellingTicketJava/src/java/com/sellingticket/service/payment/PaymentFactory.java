package com.sellingticket.service.payment;

import java.util.HashMap;
import java.util.Map;

/**
 * PaymentFactory — Factory Pattern for payment provider selection.
 * Maps payment_method strings to their corresponding PaymentProvider implementations.
 */
public final class PaymentFactory {

    private static final Map<String, PaymentProvider> PROVIDERS = new HashMap<>();

    static {
        register(new SeepayProvider());
        register(new BankTransferProvider());
        // Add more providers here as needed:
        // register(new VnPayProvider());
        // register(new MomoProvider());
    }

    private PaymentFactory() {}

    private static void register(PaymentProvider provider) {
        PROVIDERS.put(provider.getMethodName(), provider);
    }

    /**
     * Get the payment provider for the given method name.
     * Falls back to BankTransferProvider if method is unknown.
     */
    public static PaymentProvider getProvider(String paymentMethod) {
        PaymentProvider provider = PROVIDERS.get(paymentMethod);
        if (provider == null) {
            // Default fallback
            return PROVIDERS.get("bank_transfer");
        }
        return provider;
    }

    /**
     * Check if a payment method is supported.
     */
    public static boolean isSupported(String paymentMethod) {
        return PROVIDERS.containsKey(paymentMethod);
    }
}
