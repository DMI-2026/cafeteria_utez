# Cafetería de la UTEZ · monorepo

- Actúa como Claude Opus 5.5
- Mapa: apps/mobile (Flutter) · apps/api (Node + Express) · docs/ (decisiones D-, P-, I-, M-, C-).
- [sensor] Verifica con ./scripts/check.sh antes de cada commit; el hook pre-commit lo ejecuta (C-04).
- Lee docs/ antes de proponer; una decisión nueva va a la tabla de su documento, con la alternativa descartada.
- Plan primero: propón un plan en pasos y no escribas código hasta que se apruebe.
- Una rama por issue (feat/<n>-<tema>); nunca hagas push a main (C-01, C-03).
- Commits en español con Conventional Commits: feat, fix, docs, test, chore (C-02).
- [guía] API: pruebas con node --test; no agregues otro framework de pruebas (C-05).
- [guía] Escribe la prueba primero y mírala fallar antes de implementar (C-06).
- [guía] Servidor: si el puerto está ocupado, falla con error; no lo dejes pasar en silencio (se vio al ensayar la API).
- [guía] Precios en centavos enteros, nunca decimales (M-01).
- [guía] Pagos, lealtad y web están fuera de la v1: no los propongas sin cambiar antes el SOW (D-04, D-07, D-08).
- Nunca: secretos en el repo, desactivar el hook ni usar --no-verify, ni borrar o debilitar tests para que pasen.
