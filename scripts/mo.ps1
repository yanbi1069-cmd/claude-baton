# Mở Claude Code bằng một tài khoản (gọi từ lối tắt Desktop qua mo.cmd).
param(
  [Parameter(Mandatory = $true)][int]$Tk,
  [switch]$ChiIn,          # chạy thử: in lệnh, không mở Claude
  [string]$DuAn = ''       # chạy thử: thư mục dự án, khỏi hỏi
)
$Chung = Split-Path -Parent $PSScriptRoot
$H = Split-Path -Parent $Chung
$cfg = Get-Content (Join-Path $Chung 'cau-hinh.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$tkInfo = $cfg.tai_khoan | Where-Object { [int]$_.so -eq $Tk }
if (-not $tkInfo) { Write-Host "Không có tài khoản số $Tk. Gõ 'cài nhiều tài khoản' trong Claude Code để cài lại." -ForegroundColor Red; if (-not $ChiIn) { Read-Host 'Enter để đóng' }; exit 1 }
try { $Host.UI.RawUI.WindowTitle = "Claude TK$Tk - $($tkInfo.ten)" } catch {}

# Bảng usage (nếu đã có script)
$xem = Join-Path $PSScriptRoot 'xem-usage.ps1'
if ((Test-Path $xem) -and -not $ChiIn) { & $xem; Write-Host '' }

# Thư mục dự án
$cuoiFile = Join-Path $Chung "du-an-cuoi-tk$Tk.txt"
$cuoi = if (Test-Path $cuoiFile) { (Get-Content $cuoiFile -Raw -Encoding UTF8).Trim() } else { '' }
if (-not $DuAn) {
  Write-Host "TK$Tk - $($tkInfo.ten)" -ForegroundColor Cyan
  $goiY = if ($cuoi) { " (Enter = $cuoi)" } else { '' }
  $DuAn = Read-Host "Dán đường dẫn thư mục dự án$goiY"
  if (-not $DuAn) { $DuAn = $cuoi }
}
$DuAn = $DuAn.Trim().Trim('"')
if (-not $DuAn -or -not (Test-Path -LiteralPath $DuAn -PathType Container)) {
  Write-Host "Không thấy thư mục: '$DuAn'" -ForegroundColor Red; if (-not $ChiIn) { Read-Host 'Enter để đóng' }; exit 1
}
[IO.File]::WriteAllText($cuoiFile, $DuAn, (New-Object System.Text.UTF8Encoding $false))

# Có bàn giao thì hỏi nhận việc
$nhan = $false
if (Test-Path -LiteralPath (Join-Path $DuAn 'BAN-GIAO.md')) {
  if ($ChiIn) { $nhan = $true }
  else { $tl = Read-Host 'Thư mục này có BAN-GIAO.md. Nhận việc từ bản bàn giao? (C/k)'; $nhan = ($tl -eq '' -or $tl -match '^[cCyY]') }
}

$env:CLAUDE_CONFIG_DIR = $tkInfo.thu_muc
$claudeArgs = if ($nhan) { @('nhận việc') } else { @() }
if ($ChiIn) {
  Write-Output "CLAUDE_CONFIG_DIR=$($env:CLAUDE_CONFIG_DIR)"
  Write-Output "CWD=$DuAn"
  Write-Output ("LENH=claude " + ($claudeArgs -join ' '))
  exit 0
}
Set-Location -LiteralPath $DuAn
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { Write-Host 'Chưa cài Claude Code (không thấy lệnh claude).' -ForegroundColor Red; Read-Host 'Enter để đóng'; exit 1 }
Write-Host "Lần đầu dùng tài khoản này: gõ /login và đăng nhập đúng tài khoản '$($tkInfo.ten)'." -ForegroundColor DarkGray
& claude @claudeArgs
