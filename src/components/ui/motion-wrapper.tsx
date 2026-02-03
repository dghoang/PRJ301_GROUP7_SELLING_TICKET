import { motion, HTMLMotionProps } from "framer-motion";
import { forwardRef } from "react";
import { cn } from "@/lib/utils";
import {
  fadeIn,
  fadeInUp,
  scaleIn,
  staggerContainer,
  staggerItem,
} from "@/lib/animations";

// Motion variants of common elements
export const MotionDiv = motion.div;
export const MotionSection = motion.section;
export const MotionArticle = motion.article;
export const MotionUl = motion.ul;
export const MotionLi = motion.li;
export const MotionSpan = motion.span;

const transition = { duration: 0.4, ease: "easeOut" as const };

// Page wrapper with fade animation
interface PageWrapperProps extends HTMLMotionProps<"div"> {
  children: React.ReactNode;
}

export const PageWrapper = forwardRef<HTMLDivElement, PageWrapperProps>(
  ({ children, className, ...props }, ref) => (
    <motion.div
      ref={ref}
      initial="initial"
      animate="animate"
      exit="exit"
      variants={fadeIn}
      transition={transition}
      className={cn("min-h-screen", className)}
      {...props}
    >
      {children}
    </motion.div>
  )
);
PageWrapper.displayName = "PageWrapper";

// Staggered list container
interface StaggerContainerProps extends HTMLMotionProps<"div"> {
  children: React.ReactNode;
}

export const StaggerContainer = forwardRef<HTMLDivElement, StaggerContainerProps>(
  ({ children, className, ...props }, ref) => (
    <motion.div
      ref={ref}
      initial="initial"
      animate="animate"
      variants={staggerContainer}
      className={className}
      {...props}
    >
      {children}
    </motion.div>
  )
);
StaggerContainer.displayName = "StaggerContainer";

// Staggered item
interface StaggerItemProps extends HTMLMotionProps<"div"> {
  children: React.ReactNode;
}

export const StaggerItem = forwardRef<HTMLDivElement, StaggerItemProps>(
  ({ children, className, ...props }, ref) => (
    <motion.div
      ref={ref}
      variants={staggerItem}
      transition={transition}
      className={className}
      {...props}
    >
      {children}
    </motion.div>
  )
);
StaggerItem.displayName = "StaggerItem";

// Animated card with hover
interface AnimatedCardProps extends HTMLMotionProps<"div"> {
  children: React.ReactNode;
  hover?: boolean;
}

export const AnimatedCard = forwardRef<HTMLDivElement, AnimatedCardProps>(
  ({ children, className, hover = true, ...props }, ref) => (
    <motion.div
      ref={ref}
      initial="initial"
      animate="animate"
      variants={fadeInUp}
      whileHover={hover ? { y: -8, transition: { type: "spring", stiffness: 400, damping: 10 } } : undefined}
      transition={transition}
      className={className}
      {...props}
    >
      {children}
    </motion.div>
  )
);
AnimatedCard.displayName = "AnimatedCard";

// Scale in animation wrapper
interface ScaleInProps extends HTMLMotionProps<"div"> {
  children: React.ReactNode;
  delay?: number;
}

export const ScaleIn = forwardRef<HTMLDivElement, ScaleInProps>(
  ({ children, className, delay = 0, ...props }, ref) => (
    <motion.div
      ref={ref}
      initial="initial"
      animate="animate"
      variants={scaleIn}
      transition={{ ...transition, delay }}
      className={className}
      {...props}
    >
      {children}
    </motion.div>
  )
);
ScaleIn.displayName = "ScaleIn";

// Fade in wrapper with direction
interface FadeInProps extends HTMLMotionProps<"div"> {
  children: React.ReactNode;
  direction?: "up" | "down" | "left" | "right";
  delay?: number;
}

export const FadeIn = forwardRef<HTMLDivElement, FadeInProps>(
  ({ children, className, direction = "up", delay = 0, ...props }, ref) => {
    const getVariants = () => {
      switch (direction) {
        case "up":
          return { initial: { opacity: 0, y: 30 }, animate: { opacity: 1, y: 0 } };
        case "down":
          return { initial: { opacity: 0, y: -30 }, animate: { opacity: 1, y: 0 } };
        case "left":
          return { initial: { opacity: 0, x: 30 }, animate: { opacity: 1, x: 0 } };
        case "right":
          return { initial: { opacity: 0, x: -30 }, animate: { opacity: 1, x: 0 } };
      }
    };

    return (
      <motion.div
        ref={ref}
        initial="initial"
        animate="animate"
        variants={getVariants()}
        transition={{ ...transition, delay }}
        className={className}
        {...props}
      >
        {children}
      </motion.div>
    );
  }
);
FadeIn.displayName = "FadeIn";

// Animated counter for statistics
interface AnimatedCounterProps {
  value: number;
  duration?: number;
  prefix?: string;
  suffix?: string;
  className?: string;
}

export const AnimatedCounter = ({
  value,
  duration = 2,
  prefix = "",
  suffix = "",
  className,
}: AnimatedCounterProps) => {
  return (
    <motion.span
      className={className}
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.5 }}
    >
      <motion.span
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
      >
        {prefix}
        <motion.span
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration }}
        >
          {value.toLocaleString("vi-VN")}
        </motion.span>
        {suffix}
      </motion.span>
    </motion.span>
  );
};

// Hover scale wrapper
interface HoverScaleProps extends HTMLMotionProps<"div"> {
  children: React.ReactNode;
  scale?: number;
}

export const HoverScale = forwardRef<HTMLDivElement, HoverScaleProps>(
  ({ children, className, scale = 1.05, ...props }, ref) => (
    <motion.div
      ref={ref}
      whileHover={{ scale }}
      whileTap={{ scale: 0.98 }}
      transition={{ type: "spring", stiffness: 400, damping: 17 }}
      className={className}
      {...props}
    >
      {children}
    </motion.div>
  )
);
HoverScale.displayName = "HoverScale";
