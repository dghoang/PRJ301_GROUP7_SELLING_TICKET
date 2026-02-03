import { ReactNode } from "react";
import { OrganizerSidebar } from "./OrganizerSidebar";
import { cn } from "@/lib/utils";

interface OrganizerLayoutProps {
  children: ReactNode;
  title?: string;
  subtitle?: string;
  actions?: ReactNode;
}

const OrganizerLayout = ({
  children,
  title,
  subtitle,
  actions,
}: OrganizerLayoutProps) => {
  return (
    <div className="min-h-screen gradient-bg">
      <OrganizerSidebar />

      {/* Main Content */}
      <main className="lg:ml-64 min-h-screen">
        {/* Header */}
        {(title || actions) && (
          <header className="sticky top-0 z-20 glass-strong border-b border-white/10 px-6 py-4">
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
              <div className="pl-12 lg:pl-0">
                {title && <h1 className="text-2xl font-bold">{title}</h1>}
                {subtitle && (
                  <p className="text-muted-foreground mt-1">{subtitle}</p>
                )}
              </div>
              {actions && <div className="flex items-center gap-3">{actions}</div>}
            </div>
          </header>
        )}

        {/* Page Content */}
        <div className={cn("p-6", !title && !actions && "pt-20 lg:pt-6")}>
          {children}
        </div>
      </main>
    </div>
  );
};

export { OrganizerLayout };
