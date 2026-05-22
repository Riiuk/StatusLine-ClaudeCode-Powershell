# install-statusline.ps1
# Instala el statusline de Claude Code con barras de contexto y rate limits.
# Uso: Ejecutar en PowerShell en cualquier equipo con Claude Code instalado.

$claudeDir = "$env:USERPROFILE\.claude"
if (-not (Test-Path $claudeDir)) { New-Item -ItemType Directory -Path $claudeDir | Out-Null }

# --- Script Python ---
$pythonScript = @'
import sys, json, math, io, time, os

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

STATE = os.path.expanduser('~/.claude/statusline-state.json')

def load_state():
    try:
        with open(STATE, 'r') as f:
            return json.load(f)
    except:
        return {}

def save_state(s):
    try:
        with open(STATE, 'w') as f:
            json.dump(s, f)
    except:
        pass

data = json.load(sys.stdin)
ESC   = '\033'
RESET = ESC + '[0m'
WHITE = ESC + '[38;5;255m'

def get_color(pct):
    if pct < 50:  return ESC + '[38;5;82m'   # verde
    if pct < 80:  return ESC + '[38;5;214m'  # naranja/amarillo
    return ESC + '[38;5;196m'                 # rojo

def bar(pct, length):
    filled = min(math.floor(pct * length / 100), length)
    empty  = length - filled
    b = chr(0x2588) * filled + chr(0x2591) * empty
    color = get_color(pct)
    return f"{color}[{b}]{WHITE}"

def fmt_tok(n):
    return f"{round(n/1000,1)}k" if n >= 1000 else str(n)

def fmt_time(secs):
    if secs <= 0: return 'ahora'
    d = secs // 86400
    h = (secs % 86400) // 3600
    m = (secs % 3600) // 60
    if d > 0: return f"{d}d{h}h"
    if h > 0: return f"{h}h{m:02d}m"
    return f"{m}m"

state       = load_state()
now         = int(time.time())
session_id  = data.get('session_id', '')
ctx         = data.get('context_window', {})
current_tot = ctx.get('total_input_tokens', 0) + ctx.get('total_output_tokens', 0)
rl          = data.get('rate_limits') or {}
five_rst    = int((rl.get('five_hour') or {}).get('resets_at', 0))
seven_rst   = int((rl.get('seven_day') or {}).get('resets_at', 0))

if five_rst  != state.get('five_rst',  0): state['five_acc']  = 0; state['five_rst']  = five_rst
if seven_rst != state.get('seven_rst', 0): state['seven_acc'] = 0; state['seven_rst'] = seven_rst

if session_id != state.get('session_id', ''):
    prev_delta = max(0, state.get('last_total', state.get('session_base', 0)) - state.get('session_base', 0))
    state['five_acc']    = state.get('five_acc',  0) + prev_delta
    state['seven_acc']   = state.get('seven_acc', 0) + prev_delta
    state['session_id']  = session_id
    state['session_base'] = current_tot

session_delta  = max(0, current_tot - state.get('session_base', current_tot))
five_tok       = state.get('five_acc',  0) + session_delta
seven_tok      = state.get('seven_acc', 0) + session_delta
state['last_total'] = current_tot
save_state(state)

model   = (data.get('model') or {}).get('display_name', 'Claude')
tok_s   = f"Tokens: {fmt_tok(session_delta)}"

dur_ms  = (data.get('cost') or {}).get('total_duration_ms', 0)
dur_s   = round(dur_ms / 1000)
dur_str = f"Sesion: {dur_s//60}m{dur_s%60:02d}s" if dur_s >= 60 else f"Sesion: {dur_s}s"

used = int(ctx.get('used_percentage', 0) or 0)

rates = []
for key, label, acc_tok in [('five_hour', '5h', five_tok), ('seven_day', '7d', seven_tok)]:
    if key not in rl: continue
    item     = rl[key]
    used_pct = int(item.get('used_percentage', 0))
    rst      = fmt_time(max(0, int(item.get('resets_at', 0)) - now))
    b        = bar(used_pct, 10)
    rates.append(f"{label}:{b} {used_pct}% ↺ {rst} ({fmt_tok(acc_tok)})")

ctx_str = f"Contexto: {bar(used, 20)} {used}%"

grp1 = ' | '.join([model, tok_s, dur_str])
grp2 = '  '.join(rates) if rates else ''
grp3 = ctx_str

if grp2:
    out = ' | '.join([grp1, grp3]) + '\n' + grp2
else:
    out = ' | '.join(filter(None, [grp1, grp3]))

sys.stdout.write(f"{WHITE}{out}{RESET}")
sys.stdout.flush()
'@

$pythonPath = "$claudeDir\statusline-command.py"
Set-Content -Path $pythonPath -Value $pythonScript -Encoding UTF8
Write-Host "OK  Script Python guardado en: $pythonPath" -ForegroundColor Green

# --- settings.json ---
$settingsPath = "$claudeDir\settings.json"
$settings = @{}
if (Test-Path $settingsPath) {
    try {
        $settings = Get-Content $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
        # Convertir PSCustomObject a hashtable para poder modificarlo
        $ht = @{}
        $settings.PSObject.Properties | ForEach-Object { $ht[$_.Name] = $_.Value }
        $settings = $ht
    } catch {
        Write-Host "AVISO: No se pudo leer settings.json existente, se creara de cero." -ForegroundColor Yellow
        $settings = @{}
    }
}

$settings['statusline'] = @{
    type    = 'command'
    command = 'python ~/.claude/statusline-command.py'
}

$settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8
Write-Host "OK  settings.json actualizado: $settingsPath" -ForegroundColor Green

# --- Verificar Python ---
$pythonOk = $null -ne (Get-Command python -ErrorAction SilentlyContinue)
if ($pythonOk) {
    Write-Host "OK  Python encontrado en PATH." -ForegroundColor Green
} else {
    Write-Host "AVISO: Python no encontrado en PATH. Instalalo desde https://www.python.org/downloads/" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Instalacion completa. Reinicia Claude Code para ver el statusline." -ForegroundColor Cyan
