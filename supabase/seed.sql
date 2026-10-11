insert into public.temple_settings (temple_name, default_locale)
values ('Temple Name To Be Decided','en')
on conflict do nothing;

insert into public.accounts (code, name_en, name_kn, type) values
('1000','Cash on Hand','ನಗದು','asset'),
('1010','Bank Account','ಬ್ಯಾಂಕ್ ಖಾತೆ','asset'),
('1020','Payment Gateway Clearing','ಪಾವತಿ ಗೇಟ್‌ವೇ ಬಾಕಿ','asset'),
('2000','Refunds Payable','ಮರುಪಾವತಿ ಬಾಕಿ','liability'),
('3000','Temple Fund Balance','ದೇವಾಲಯ ನಿಧಿ ಶಿಲ್ಕು','fund_balance'),
('4000','Seva Income','ಸೇವಾ ಆದಾಯ','income'),
('4010','Donations - General','ಸಾಮಾನ್ಯ ದೇಣಿಗೆ','income'),
('4020','Donations - Restricted Purpose','ನಿರ್ದಿಷ್ಟ ಉದ್ದೇಶದ ದೇಣಿಗೆ','liability'),
('5000','Pooja Materials Expense','ಪೂಜಾ ಸಾಮಗ್ರಿ ವೆಚ್ಚ','expense'),
('5010','Utilities Expense','ವಿದ್ಯುತ್ ಮತ್ತು ನೀರಿನ ವೆಚ್ಚ','expense'),
('5020','Event Expense','ಕಾರ್ಯಕ್ರಮ ವೆಚ್ಚ','expense')
on conflict (code) do nothing;
