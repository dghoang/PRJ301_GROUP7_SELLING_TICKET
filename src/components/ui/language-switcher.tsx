import { useTranslation } from "react-i18next";
import { languages } from "@/i18n";
import { cn } from "@/lib/utils";
import { Globe, Check } from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

interface LanguageSwitcherProps {
  variant?: "icon" | "full";
  className?: string;
}

const LanguageSwitcher = ({ variant = "icon", className }: LanguageSwitcherProps) => {
  const { i18n } = useTranslation();
  const currentLang = languages.find((l) => l.code === i18n.language) || languages[0];

  const handleLanguageChange = (langCode: string) => {
    i18n.changeLanguage(langCode);
  };

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button
          className={cn(
            "flex items-center gap-2 p-2 rounded-xl glass hover:bg-accent/50 transition-colors",
            variant === "full" && "px-3",
            className
          )}
        >
          {variant === "icon" ? (
            <Globe className="w-5 h-5 text-muted-foreground" />
          ) : (
            <>
              <span className="text-lg">{currentLang.flag}</span>
              <span className="text-sm font-medium">{currentLang.code.toUpperCase()}</span>
            </>
          )}
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="glass-strong border-white/10 min-w-[160px]">
        {languages.map((lang) => (
          <DropdownMenuItem
            key={lang.code}
            onClick={() => handleLanguageChange(lang.code)}
            className={cn(
              "flex items-center justify-between gap-3 cursor-pointer",
              i18n.language === lang.code && "bg-primary/10"
            )}
          >
            <div className="flex items-center gap-2">
              <span className="text-lg">{lang.flag}</span>
              <span>{lang.name}</span>
            </div>
            {i18n.language === lang.code && (
              <Check className="w-4 h-4 text-primary" />
            )}
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  );
};

export { LanguageSwitcher };
