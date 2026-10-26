# Contribuidores y Control de Cambios · Cafetería de la UTEZ

> Este documento establece el padrón oficial de integrantes del espacio de la organización **DMI-2026** (Desarrollo Móvil Integral, UTEZ) y define los lineamientos normativos para el control y la trazabilidad de los cambios en el monorepo.

---

## 1. Padrón Oficial de Contribuidores (DMI-2026)

Lista de los 31 miembros registrados en la organización de GitHub [DMI-2026](https://github.com/DMI-2026):

| # | Usuario GitHub | Nombre / Identificador | Rol / Área asignada | Estado |
|:---:|---|---|---|:---:|
| 1 | [@20213tn098](https://github.com/20213tn098) | Jose Arias | Contribuidor | Activo |
| 2 | [@20233tn193](https://github.com/20233tn193) | Juan Manuel Chavez Arredondo | Contribuidor | Activo |
| 3 | [@Aldahir9812](https://github.com/Aldahir9812) | Alejandro Aldahir Torres Galvan | Contribuidor | Activo |
| 4 | [@AlexReyes03](https://github.com/AlexReyes03) | Isael Alejandro Reyes Vargas | Contribuidor | Activo |
| 5 | [@AlexandraHernandez16](https://github.com/AlexandraHernandez16) | Katia Hernández | Contribuidor | Activo |
| 6 | [@Aqquinou](https://github.com/Aqquinou) | Andrea Aquino | Contribuidor | Activo |
| 7 | [@DavidReds7](https://github.com/DavidReds7) | David Rojas | Contribuidor | Activo |
| 8 | [@GaelCast9](https://github.com/GaelCast9) | Gael Castro | Contribuidor | Activo |
| 9 | [@HannaCast](https://github.com/HannaCast) | Hanna Romybsi Pérez Caspeta | Contribuidor | Activo |
| 10 | [@IgnacioValera](https://github.com/IgnacioValera) | Ignacio Valera | Contribuidor | Activo |
| 11 | [@Jafetvu](https://github.com/Jafetvu) | Jafet Bahena González | Contribuidor | Activo |
| 12 | [@Jassiel75](https://github.com/Jassiel75) | Jassiel Paredes Dominguez | Contribuidor | Activo |
| 13 | [@JesusDre](https://github.com/JesusDre) | Jesus Juarez | Contribuidor | Activo |
| 14 | [@JoseLuisMirRo](https://github.com/JoseLuisMirRo) | Jose Luis Miranda Roldán | Contribuidor | Activo |
| 15 | [@Josue-rg](https://github.com/Josue-rg) | Josue RG | Contribuidor | Activo |
| 16 | [@LARISSA1825alita](https://github.com/LARISSA1825alita) | Alison Larissa Martinez | Contribuidor | Activo |
| 17 | [@LaloAleman18](https://github.com/LaloAleman18) | José Eduardo Casarrubias Aleman | Contribuidor | Activo |
| 18 | [@LeobardoVillalobos88](https://github.com/LeobardoVillalobos88) | Leobardo Villalobos | Contribuidor | Activo |
| 19 | [@Loreley100](https://github.com/Loreley100) | Loreley | Contribuidor | Activo |
| 20 | [@M4ltin12](https://github.com/M4ltin12) | Martin Antonio JL | Contribuidor | Activo |
| 21 | [@MiguelSP040](https://github.com/MiguelSP040) | Miguel Angel Sanchez Perez | Contribuidor | Activo |
| 22 | [@MrAngelovsky](https://github.com/MrAngelovsky) | Angel Aguilar | Contribuidor | Activo |
| 23 | [@Nadia05Sa](https://github.com/Nadia05Sa) | Nadia Yuridia Salinas Cervantes | Contribuidor | Activo |
| 24 | [@VictorBrito13](https://github.com/VictorBrito13) | Victor Brito | Contribuidor | Activo |
| 25 | [@adircracknew26](https://github.com/adircracknew26) | PanAdir | Contribuidor | Activo |
| 26 | [@carsimax](https://github.com/carsimax) | Maximiliano Carsi | Docente / Coordinador | Activo |
| 27 | [@daniel-leon-flores](https://github.com/daniel-leon-flores) | Axel Daniel León Flores | Contribuidor | Activo |
| 28 | [@danielita05](https://github.com/danielita05) | Daniela Carrate Bahena | Contribuidor | Activo |
| 29 | [@dsanchezz](https://github.com/dsanchezz) | Danna Paola Sánchez Martínez | Contribuidor | Activo |
| 30 | [@kuisser116](https://github.com/kuisser116) | Sergio Jhoel Garduño Cruz | Contribuidor | Activo |
| 31 | [@philarvz](https://github.com/philarvz) | Pilar Higareda | Contribuidor | Activo |

---

## 2. Lineamientos para el Control de Cambios

Para garantizar la estabilidad del proyecto, cada persona contribuidora debe apegarse estrictamente a las convenciones de trabajo vigentes:

### A. Política de ramas (C-01)
- **Nunca hacer push directo a `main`**.
- Trabajar en ramas aisladas basadas en issues:
  - Funcionalidades: `feat/<número-issue>-<descripción-corta>` (ej. `feat/1-crud-productos`)
  - Correcciones de errores: `fix/<número-issue>-<descripción-corta>` (ej. `fix/4-puerto-api`)
  - Documentación o tareas de mantenimiento: `docs/<tema>` o `chore/<tema>`

### B. Formato de commits (C-02)
- Usar **Conventional Commits en español**:
  - `feat: <descripción del nuevo requerimiento>`
  - `fix: <descripción de la corrección>`
  - `docs: <cambios en la documentación>`
  - `test: <incorporación o modificación de pruebas>`
  - `chore: <mantenimiento, dependencias o configuración>`
- Mantener mensajes concisos, descriptivos y en tiempo presente.

### C. El Sensor y verificación local obligatoria (C-04)
- Antes de cada commit, debe ejecutarse `./scripts/check.sh`.
- El hook pre-commit instalado en `.githooks` rechaza automáticamente cualquier commit que no pase el análisis o cuyas pruebas fallen.
- **Prohibido** usar `--no-verify` o saltarse las pruebas.

### D. Pruebas y TDD (C-05, C-06)
- Toda nueva característica o corrección debe acompañarse de su prueba correspondiente.
- Backend: pruebas con `node --test` (sin frameworks externos como Jest).
- Flutter: pruebas unitarias y de widgets con `flutter test`.
- Se sigue el ciclo: escribir la prueba primero, verla fallar y luego implementar hasta que pase.

### E. Flujo de Pull Requests y Revisión por Pares (C-03)
1. Abrir el Pull Request apuntando a `main` referenciando el issue correspondiente (`Closes #<número>`).
2. Todo PR debe ser revisado y aprobado por al menos **otra persona del equipo** antes de fusionarse.
3. El autor del PR no puede autoaprobar su contribución.
4. Una vez aprobado y con los checks en verde, se realiza la integración a `main`.
