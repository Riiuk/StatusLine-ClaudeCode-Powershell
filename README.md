# Claude Code Statusline — Instalador PowerShell

Muestra en tiempo real en la parte inferior de Claude Code:

- Modelo activo | Tokens de sesión | Duración de sesión
- Barra de uso del contexto (con color según nivel)
- Barras de rate limit **5h** y **7d** con porcentaje y tiempo hasta reset

![Ejemplo de statusline con barras de contexto y rate limits]()

---

## Requisitos

- [Claude Code](https://claude.ai/code) instalado
- [Python 3](https://www.python.org/downloads/) instalado y en el PATH del sistema  
  _(durante la instalación marca **"Add Python to PATH"*)_

---

## Instalación

1. Descarga o clona este repositorio en cualquier carpeta del equipo.

2. Abre **PowerShell** (búscalo en el menú Inicio).

3. Si es la primera vez que ejecutas scripts en este equipo, habilita la ejecución:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   ```
   Confirma con `S`.

4. Navega hasta la carpeta y ejecuta el instalador:
   ```powershell
   .\install-statusline.ps1
   ```

5. **Reinicia Claude Code.**

El script crea automáticamente `~/.claude/statusline-command.py` y añade la configuración en `~/.claude/settings.json` **sin borrar ninguna configuración existente**.

---

## Qué hace el instalador

| Archivo generado | Descripción |
|---|---|
| `~/.claude/statusline-command.py` | Script Python que genera el statusline |
| `~/.claude/settings.json` | Añade la clave `statusline` con el comando |

---

## Desinstalación

1. Elimina la sección `statusline` de `~/.claude/settings.json`.
2. Borra `~/.claude/statusline-command.py` si lo deseas.

---

## Compatibilidad

Probado en **Windows 11** con PowerShell 5.1. Requiere Python 3 en el PATH.
