# Contribuidores y Control de Cambios · Cafetería de la UTEZ

> Este documento establece el padrón oficial de integrantes del espacio de la organización **DMI-2026** (Desarrollo Móvil Integral, UTEZ) y define los lineamientos normativos para el control y la trazabilidad de los cambios en el monorepo.

---

## 1. Padrón Oficial de Contribuidores (DMI-2026)

La organización de GitHub [DMI-2026](https://github.com/DMI-2026) tiene 31 miembros: el docente y 30 alumnos repartidos en 5 equipos de 6. Los equipos están dados de alta en la organización ([Teams](https://github.com/orgs/DMI-2026/teams)); el docente pertenece a todos.

**Docente / Coordinador:** [@carsimax](https://github.com/carsimax) · Maximiliano Carsi

### Equipo 1 (`team-1`)

| # | Usuario GitHub | Nombre / Identificador | Estado |
|:---:|---|---|:---:|
| 1 | [@DavidReds7](https://github.com/DavidReds7) | David Rojas | Activo |
| 2 | [@Nadia05Sa](https://github.com/Nadia05Sa) | Nadia Yuridia Salinas Cervantes | Activo |
| 3 | [@JesusDre](https://github.com/JesusDre) | Jesus Juarez | Activo |
| 4 | [@LARISSA1825alita](https://github.com/LARISSA1825alita) | Alison Larissa Martinez | Activo |
| 5 | [@HannaCast](https://github.com/HannaCast) | Hanna Romybsi Pérez Caspeta | Activo |
| 6 | [@20233tn193](https://github.com/20233tn193) | Juan Manuel Chavez Arredondo | Activo |

### Equipo 2 (`team-2`)

| # | Usuario GitHub | Nombre / Identificador | Estado |
|:---:|---|---|:---:|
| 1 | [@MiguelSP040](https://github.com/MiguelSP040) | Miguel Angel Sanchez Perez | Activo |
| 2 | [@danielita05](https://github.com/danielita05) | Daniela Carrate Bahena | Activo |
| 3 | [@Jafetvu](https://github.com/Jafetvu) | Jafet Bahena González | Activo |
| 4 | [@M4ltin12](https://github.com/M4ltin12) | Martin Antonio JL | Activo |
| 5 | [@AlexReyes03](https://github.com/AlexReyes03) | Isael Alejandro Reyes Vargas | Activo |
| 6 | [@Loreley100](https://github.com/Loreley100) | Loreley | Activo |

### Equipo 3 (`team-3`)

| # | Usuario GitHub | Nombre / Identificador | Estado |
|:---:|---|---|:---:|
| 1 | [@dsanchezz](https://github.com/dsanchezz) | Danna Paola Sánchez Martínez | Activo |
| 2 | [@Aqquinou](https://github.com/Aqquinou) | Andrea Aquino | Activo |
| 3 | [@daniel-leon-flores](https://github.com/daniel-leon-flores) | Axel Daniel León Flores | Activo |
| 4 | [@philarvz](https://github.com/philarvz) | Pilar Higareda | Activo |
| 5 | [@JoseLuisMirRo](https://github.com/JoseLuisMirRo) | Jose Luis Miranda Roldán | Activo |
| 6 | [@AlexandraHernandez16](https://github.com/AlexandraHernandez16) | Katia Hernández | Activo |

### Equipo 4 (`team-4`)

| # | Usuario GitHub | Nombre / Identificador | Estado |
|:---:|---|---|:---:|
| 1 | [@20213tn098](https://github.com/20213tn098) | Jose Arias | Activo |
| 2 | [@LeobardoVillalobos88](https://github.com/LeobardoVillalobos88) | Leobardo Villalobos | Activo |
| 3 | [@MrAngelovsky](https://github.com/MrAngelovsky) | Angel Aguilar | Activo |
| 4 | [@Aldahir9812](https://github.com/Aldahir9812) | Alejandro Aldahir Torres Galvan | Activo |
| 5 | [@Jassiel75](https://github.com/Jassiel75) | Jassiel Paredes Dominguez | Activo |
| 6 | [@IgnacioValera](https://github.com/IgnacioValera) | Ignacio Valera | Activo |

### Equipo 5 (`team-5`)

| # | Usuario GitHub | Nombre / Identificador | Estado |
|:---:|---|---|:---:|
| 1 | [@VictorBrito13](https://github.com/VictorBrito13) | Victor Brito | Activo |
| 2 | [@kuisser116](https://github.com/kuisser116) | Sergio Jhoel Garduño Cruz | Activo |
| 3 | [@adircracknew26](https://github.com/adircracknew26) | PanAdir | Activo |
| 4 | [@LaloAleman18](https://github.com/LaloAleman18) | José Eduardo Casarrubias Aleman | Activo |
| 5 | [@GaelCast9](https://github.com/GaelCast9) | Gael Castro | Activo |
| 6 | [@Josue-rg](https://github.com/Josue-rg) | Josue RG | Activo |

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
