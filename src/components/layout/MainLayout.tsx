import { ReactNode } from "react";
import { Header } from "./Header";
import { Footer } from "./Footer";
import { cn } from "@/lib/utils";

interface MainLayoutProps {
  children: ReactNode;
  showHeader?: boolean;
  showFooter?: boolean;
  headerVariant?: "default" | "transparent";
  className?: string;
  gradientBg?: boolean;
}

const MainLayout = ({
  children,
  showHeader = true,
  showFooter = true,
  headerVariant = "default",
  className,
  gradientBg = true,
}: MainLayoutProps) => {
  return (
    <div className={cn("min-h-screen flex flex-col", gradientBg && "gradient-bg")}>
      {showHeader && <Header variant={headerVariant} />}
      <main className={cn("flex-1 pt-20", className)}>{children}</main>
      {showFooter && <Footer />}
    </div>
  );
};

export { MainLayout };
