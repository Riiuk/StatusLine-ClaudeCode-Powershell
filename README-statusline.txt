STATUSLINE PARA CLAUDE CODE — Instrucciones de instalación
============================================================

Muestra en tiempo real en la parte inferior de Claude Code:
  - Modelo activo | Tokens de sesión | Duración de sesión | Barra de contexto
  - Barras de uso de rate limits (5h y 7d) con % y tiempo hasta reset


REQUISITOS
----------
- Claude Code instalado (https://claude.ai/code)
- Python 3 instalado y en el PATH del sistema
  Si no lo tienes: https://www.python.org/downloads/
  (marca "Add Python to PATH" durante la instalación)


INSTALACIÓN
-----------
1. Copia los dos archivos de este ZIP a cualquier carpeta del equipo.

2. Abre PowerShell (busca "PowerShell" en el menú Inicio).

3. Si es la primera vez que ejecutas scripts en este equipo, escribe:
      Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   y confirma con "S".

4. Navega hasta la carpeta donde copiaste los archivos y ejecuta:
      .\install-statusline.ps1

5. Reinicia Claude Code.

El script crea automáticamente ~/.claude/statusline-command.py
y añade la configuración necesaria en ~/.claude/settings.json
sin borrar ninguna configuración que ya tuvieras.


DESINSTALACIÓN
--------------
Elimina la sección "statusline" de ~/.claude/settings.json
y borra ~/.claude/statusline-command.py si lo deseas.
