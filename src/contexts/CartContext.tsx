import { createContext, useContext, useState, useEffect, ReactNode } from "react";
import { STORAGE_KEYS } from "@/config/constants";
import type { TicketType, Event, EventSchedule } from "@/types";

// ==========================================
// CART TYPES
// ==========================================

export interface CartItem {
  ticketType: TicketType;
  quantity: number;
}

export interface CartState {
  event: Event | null;
  schedule: EventSchedule | null;
  items: CartItem[];
  holdExpiry: number | null; // Unix timestamp
}

interface CartContextType {
  cart: CartState;
  addToCart: (event: Event, schedule: EventSchedule | null, ticketType: TicketType, quantity: number) => void;
  updateQuantity: (ticketTypeId: string, quantity: number) => void;
  removeFromCart: (ticketTypeId: string) => void;
  clearCart: () => void;
  getSubtotal: () => number;
  getTotalItems: () => number;
  isHoldExpired: () => boolean;
  getRemainingHoldTime: () => number; // seconds
  startHoldTimer: (seconds: number) => void;
}

const initialCartState: CartState = {
  event: null,
  schedule: null,
  items: [],
  holdExpiry: null,
};

const CartContext = createContext<CartContextType | undefined>(undefined);

// ==========================================
// CART PROVIDER
// ==========================================

interface CartProviderProps {
  children: ReactNode;
}

export function CartProvider({ children }: CartProviderProps) {
  const [cart, setCart] = useState<CartState>(() => {
    // Initialize from localStorage
    const stored = localStorage.getItem(STORAGE_KEYS.CART);
    if (stored) {
      try {
        const parsed = JSON.parse(stored);
        // Check if hold is expired
        if (parsed.holdExpiry && Date.now() > parsed.holdExpiry) {
          return initialCartState;
        }
        return parsed;
      } catch {
        return initialCartState;
      }
    }
    return initialCartState;
  });

  // Persist cart to localStorage
  useEffect(() => {
    localStorage.setItem(STORAGE_KEYS.CART, JSON.stringify(cart));
  }, [cart]);

  // Check hold expiry periodically
  useEffect(() => {
    if (!cart.holdExpiry) return;

    const checkExpiry = () => {
      if (Date.now() > cart.holdExpiry!) {
        clearCart();
      }
    };

    const interval = setInterval(checkExpiry, 1000);
    return () => clearInterval(interval);
  }, [cart.holdExpiry]);

  const addToCart = (
    event: Event,
    schedule: EventSchedule | null,
    ticketType: TicketType,
    quantity: number
  ) => {
    setCart((prev) => {
      // If different event, clear cart first
      if (prev.event && prev.event.id !== event.id) {
        return {
          event,
          schedule,
          items: [{ ticketType, quantity }],
          holdExpiry: prev.holdExpiry,
        };
      }

      // Check if item already exists
      const existingIndex = prev.items.findIndex(
        (item) => item.ticketType.id === ticketType.id
      );

      if (existingIndex > -1) {
        const newItems = [...prev.items];
        newItems[existingIndex] = {
          ...newItems[existingIndex],
          quantity: newItems[existingIndex].quantity + quantity,
        };
        return { ...prev, event, schedule, items: newItems };
      }

      return {
        ...prev,
        event,
        schedule,
        items: [...prev.items, { ticketType, quantity }],
      };
    });
  };

  const updateQuantity = (ticketTypeId: string, quantity: number) => {
    setCart((prev) => ({
      ...prev,
      items: prev.items.map((item) =>
        item.ticketType.id === ticketTypeId
          ? { ...item, quantity: Math.max(0, quantity) }
          : item
      ).filter((item) => item.quantity > 0),
    }));
  };

  const removeFromCart = (ticketTypeId: string) => {
    setCart((prev) => ({
      ...prev,
      items: prev.items.filter((item) => item.ticketType.id !== ticketTypeId),
    }));
  };

  const clearCart = () => {
    setCart(initialCartState);
    localStorage.removeItem(STORAGE_KEYS.CART);
  };

  const getSubtotal = () => {
    return cart.items.reduce(
      (total, item) => total + item.ticketType.price * item.quantity,
      0
    );
  };

  const getTotalItems = () => {
    return cart.items.reduce((total, item) => total + item.quantity, 0);
  };

  const isHoldExpired = () => {
    if (!cart.holdExpiry) return false;
    return Date.now() > cart.holdExpiry;
  };

  const getRemainingHoldTime = () => {
    if (!cart.holdExpiry) return 0;
    const remaining = Math.max(0, cart.holdExpiry - Date.now());
    return Math.floor(remaining / 1000);
  };

  const startHoldTimer = (seconds: number) => {
    setCart((prev) => ({
      ...prev,
      holdExpiry: Date.now() + seconds * 1000,
    }));
  };

  const value: CartContextType = {
    cart,
    addToCart,
    updateQuantity,
    removeFromCart,
    clearCart,
    getSubtotal,
    getTotalItems,
    isHoldExpired,
    getRemainingHoldTime,
    startHoldTimer,
  };

  return <CartContext.Provider value={value}>{children}</CartContext.Provider>;
}

// ==========================================
// USE CART HOOK
// ==========================================

export function useCart() {
  const context = useContext(CartContext);
  if (context === undefined) {
    throw new Error("useCart must be used within a CartProvider");
  }
  return context;
}
