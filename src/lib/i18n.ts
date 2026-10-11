export type Locale = "en" | "kn";

export const messages = {
  en: {
    home: "Home",
    sevas: "Pooja & Seva",
    events: "Events",
    calendar: "Temple Calendar",
    gallery: "Photo Gallery",
    admin: "Admin Portal",
    welcome: "Temple services, events and seva bookings",
    welcomeBody: "View upcoming events, explore available sevas and stay connected with the temple.",
    upcoming: "Upcoming events",
    viewSevas: "Explore sevas",
    manage: "Management dashboard",
    dashboardBody: "Sign in with an authorized account to manage bookings, accounts, events and photos.",
    bilingualNote: "Language can be switched between English and Kannada."
  },
  kn: {
    home: "ಮುಖಪುಟ",
    sevas: "ಪೂಜೆ ಮತ್ತು ಸೇವೆ",
    events: "ಕಾರ್ಯಕ್ರಮಗಳು",
    calendar: "ದೇವಾಲಯದ ಕ್ಯಾಲೆಂಡರ್",
    gallery: "ಫೋಟೋ ಗ್ಯಾಲರಿ",
    admin: "ನಿರ್ವಹಣಾ ವಿಭಾಗ",
    welcome: "ದೇವಾಲಯದ ಸೇವೆಗಳು, ಕಾರ್ಯಕ್ರಮಗಳು ಮತ್ತು ಸೇವಾ ಬುಕ್ಕಿಂಗ್",
    welcomeBody: "ಮುಂಬರುವ ಕಾರ್ಯಕ್ರಮಗಳನ್ನು ನೋಡಿ, ಲಭ್ಯವಿರುವ ಸೇವೆಗಳನ್ನು ತಿಳಿದುಕೊಳ್ಳಿ ಮತ್ತು ದೇವಾಲಯದೊಂದಿಗೆ ಸಂಪರ್ಕದಲ್ಲಿರಿ.",
    upcoming: "ಮುಂಬರುವ ಕಾರ್ಯಕ್ರಮಗಳು",
    viewSevas: "ಸೇವೆಗಳ ವಿವರ",
    manage: "ನಿರ್ವಹಣಾ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್",
    dashboardBody: "ಬುಕ್ಕಿಂಗ್‌ಗಳು, ಲೆಕ್ಕಪತ್ರಗಳು, ಕಾರ್ಯಕ್ರಮಗಳು ಮತ್ತು ಫೋಟೋಗಳನ್ನು ನಿರ್ವಹಿಸಲು ಅನುಮೋದಿತ ಖಾತೆಯಿಂದ ಪ್ರವೇಶಿಸಿ.",
    bilingualNote: "ಭಾಷೆಯನ್ನು ಕನ್ನಡ ಮತ್ತು ಇಂಗ್ಲಿಷ್ ನಡುವೆ ಬದಲಾಯಿಸಬಹುದು."
  }
} as const;

export function getMessages(locale: Locale) {
  return messages[locale] ?? messages.en;
}
