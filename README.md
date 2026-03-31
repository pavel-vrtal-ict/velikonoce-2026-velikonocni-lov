# Velikonoční lov vajíček (v4)

Jednostránková webová hra na hledání velikonočních vajíček ve 12 scénách. Funguje na PC i na mobilu (myš i dotyk).

## Spuštění

- Otevři soubor `velikonocni_lov_v4.html` v prohlížeči.

## Sdílení pro kolegy (GitHub Pages)

1. Nahraj projekt na GitHub.
2. V repozitáři otevři **Settings → Pages**.
3. V části **Build and deployment** zvol:
   - **Source**: *Deploy from a branch*
   - **Branch**: `main` (root)
4. Ulož. GitHub ti vygeneruje veřejný odkaz.

Poznámka: výsledková listina se ukládá do `localStorage`, takže je **per zařízení / prohlížeč**.

## Školní režim: sdílené statistiky a žebříček (doporučeno)

Pro sdílené statistiky (celá škola dohromady) je potřeba jednoduché úložiště. Doporučení: **Supabase**.

### Jak to funguje s e‑mailem (soukromí)

- Ve výsledkové listině je vidět pouze **nick**.
- Do sdíleného úložiště se ukládá jen **otisk (SHA‑256 hash) e‑mailu**, ne e‑mail v čitelné podobě.
- Dohledání “kdo je za nickem” se dělá tak, že organizátor vezme e‑mail, spočítá stejný hash a vyhledá ho v tabulce.

### Nastavení Supabase (stručně)

1. V Supabase vytvoř projekt.
2. Vytvoř tabulku `vajicka_scores` se sloupci:
   - `id` (uuid, default `gen_random_uuid()`, primary key)
   - `nick` (text, not null)
   - `eggs` (int, not null)
   - `ms` (int, not null)
   - `ts` (bigint, not null)
   - `email_hash` (text, nullable)
3. Povolit pro klienta:
   - insert (aby šlo zapsat výsledek)
   - select jen na veřejná pole (ideálně přes view bez `email_hash`)
4. Do souboru `velikonocni_lov_v4.html` doplň:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
