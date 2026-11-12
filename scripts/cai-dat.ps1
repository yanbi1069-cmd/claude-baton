# Cài nhiều tài khoản Claude Code trên Windows.
# Mỗi tài khoản một thư mục cấu hình riêng (CLAUDE_CONFIG_DIR) + một lối tắt Desktop.
# Chạy lại an toàn: chỉ bổ sung phần còn thiếu, không ghi đè cấu hình đã có.
# Không tự chuyển tài khoản: người dùng tự chọn mở tài khoản nào.
param(
  [Parameter(Mandatory = $true)][ValidateRange(1, 9)][int]$SoTk,
  [string]$Ten = '',     # tên gợi nhớ, cách nhau bằng ';'  vd: "Mail A;Mail B;;Mail D" (để trống = giữ tên cũ)
  [switch]$ChepClaudeMd,
  [string]$HomeThu = ''   # chỉ dùng khi chạy thử: thay cho thư mục người dùng
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch {}
$utf8 = New-Object System.Text.UTF8Encoding $false
function GhiFile($p, $txt) { [IO.File]::WriteAllText($p, $txt, $utf8) }

$H = if ($HomeThu) { $HomeThu } else { $env:USERPROFILE }
$Desk = if ($HomeThu) { Join-Path $HomeThu 'Desktop' } else { [Environment]::GetFolderPath('Desktop') }
$Skill = Split-Path -Parent $PSScriptRoot          # thư mục skill claude-baton
$Chung = Join-Path $H '.claude-baton'           # dữ liệu chung: cấu hình, script, usage
New-Item -ItemType Directory -Force -Path $Chung, (Join-Path $Chung 'usage'), $Desk | Out-Null

# 1. Chép script sang chỗ cố định (lối tắt và status line trỏ vào đây, không phụ thuộc chỗ cài skill)
Copy-Item -Path (Join-Path $Skill 'scripts\*') -Destination (New-Item -ItemType Directory -Force -Path (Join-Path $Chung 'scripts')).FullName -Recurse -Force
$Mo = Join-Path $Chung 'scripts\mo.cmd'
$SL = Join-Path $Chung 'scripts\statusline.ps1'

# 2. Cấu hình chung (giữ tên cũ nếu đã có)
$cfgPath = Join-Path $Chung 'cau-hinh.json'
$cu = @{}
if (Test-Path $cfgPath) { (Get-Content $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json).tai_khoan | ForEach-Object { $cu[[int]$_.so] = $_.ten } }
$tenDs = @($Ten -split ';' | ForEach-Object { $_.Trim() })
$ds = @()
for ($n = 1; $n -le $SoTk; $n++) {
  $t = if ($tenDs.Count -ge $n -and $tenDs[$n - 1]) { $tenDs[$n - 1] } elseif ($cu[$n]) { $cu[$n] } else { "Tài khoản $n" }
  $ds += [pscustomobject]@{ so = $n; ten = $t; thu_muc = (Join-Path $H ".claude-tk$n") }
}
GhiFile $cfgPath (@{ tai_khoan = $ds; cap_nhat = (Get-Date).ToString('s') } | ConvertTo-Json -Depth 4)

$bao = @()
$claudeCmd = (Get-Command claude -ErrorAction SilentlyContinue).Source
$claudeExe = $null
foreach ($c in @($claudeCmd,
    (Join-Path (Split-Path -Parent "$claudeCmd") 'node_modules\@anthropic-ai\claude-code\bin\claude.exe'),
    (Join-Path $env:USERPROFILE '.local\bin\claude.exe'))) {
  if ($c -and $c -like '*.exe' -and (Test-Path $c)) { $claudeExe = $c; break }
}
foreach ($tk in $ds) {
  $dir = $tk.thu_muc
  New-Item -ItemType Directory -Force -Path $dir | Out-Null

  # 3. settings.json: thêm statusLine nếu chưa có, giữ nguyên mọi thứ khác
  $sp = Join-Path $dir 'settings.json'
  $s = if (Test-Path $sp) { Get-Content $sp -Raw -Encoding UTF8 | ConvertFrom-Json } else { [pscustomobject]@{} }
  if (-not $s.PSObject.Properties['statusLine']) {
    $cmd = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$SL`" -Tk $($tk.so)"
    $s | Add-Member -NotePropertyName statusLine -NotePropertyValue ([pscustomobject]@{ type = 'command'; command = $cmd })
    GhiFile $sp ($s | ConvertTo-Json -Depth 20)
    $bao += "TK$($tk.so): thêm thanh trạng thái"
  }

  # 4. Chép skill vào tài khoản này (để gọi được 'bàn giao', 'nhận việc', 'xem usage'); cập nhật bản mới
  $dst = Join-Path $dir 'skills\claude-baton'
  if ((Resolve-Path $Skill).Path -ne $dst) {
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    Copy-Item -Path (Join-Path $Skill '*') -Destination $dst -Recurse -Force
  }

  # 5. CLAUDE.md chung (chỉ khi người dùng muốn và tài khoản chưa có)
  $goc = Join-Path $H '.claude\CLAUDE.md'
  if ($ChepClaudeMd -and (Test-Path $goc) -and -not (Test-Path (Join-Path $dir 'CLAUDE.md'))) {
    Copy-Item $goc (Join-Path $dir 'CLAUDE.md'); $bao += "TK$($tk.so): chép CLAUDE.md chung"
  }

  # 6. Lối tắt Desktop (WScript không lưu được tên có dấu, nên lưu tên tạm rồi đổi tên)
  $ten = ("Claude TK$($tk.so) - $($tk.ten)" -replace '[\\/:*?"<>|]', '-')
  $lnk = Join-Path $Desk "$ten.lnk"
  Get-ChildItem -LiteralPath $Desk -Filter "Claude TK$($tk.so) - *.lnk" -ErrorAction SilentlyContinue | Where-Object { $_.FullName -ne $lnk } | Remove-Item -Force
  $tmp = Join-Path $Desk "baton-tam-$($tk.so).lnk"
  $w = New-Object -ComObject WScript.Shell
  $sc = $w.CreateShortcut($tmp)
  $sc.TargetPath = $Mo
  $sc.Arguments = "$($tk.so)"
  $sc.WorkingDirectory = $H
  if ($claudeExe -and $claudeExe -like '*.exe') { $sc.IconLocation = "$claudeExe,0" }
  $sc.Save()
  if (Test-Path -LiteralPath $lnk) { Remove-Item -LiteralPath $lnk -Force }
  Rename-Item -LiteralPath $tmp -NewName "$ten.lnk"
}

Write-Output "Đã cài $SoTk tài khoản."
$ds | ForEach-Object { Write-Output ("  TK{0}: {1}  ->  {2}" -f $_.so, $_.ten, $_.thu_muc) }
if ($bao) { $bao | ForEach-Object { Write-Output "  $_" } }
Write-Output "Lối tắt Desktop: $Desk"
if (-not $claudeCmd) { Write-Output 'Cảnh báo: chưa thấy lệnh claude trong PATH. Cài Claude Code trước khi bấm lối tắt.' }
