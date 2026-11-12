# Thanh trạng thái Claude Code cho từng tài khoản.
# Claude Code gửi JSON phiên qua stdin; trường rate_limits (5 giờ, 7 ngày) là số usage chính thức
# của gói Pro/Max/Ultra, chỉ có sau câu trả lời đầu tiên. Script ghi số đó vào usage\tkN.json
# để 'xem usage' đọc lại, rồi in một dòng ngắn. Không bao giờ được làm hỏng phiên: lỗi thì in tối thiểu.
param([int]$Tk = 0)
try { [Console]::InputEncoding = [Text.Encoding]::UTF8; [Console]::OutputEncoding = New-Object Text.UTF8Encoding $false } catch {}
$nhan = "TK$Tk"
try {
  $raw = [Console]::In.ReadToEnd()
  $j = $raw | ConvertFrom-Json
  function GioReset($epoch, $coNgay) {
    if (-not $epoch) { return '' }
    $d = [DateTimeOffset]::FromUnixTimeSeconds([int64]$epoch).ToLocalTime()
    if ($coNgay) { return $d.ToString('dd/MM HH:mm') } else { return $d.ToString('HH:mm') }
  }
  $phan = @($nhan)
  $canhBao = $false
  $rl = $j.rate_limits
  if ($rl) {
    $f = $rl.five_hour; $w = $rl.seven_day
    if ($f -and $null -ne $f.used_percentage) {
      $phan += ('5h {0:0}% (reset {1})' -f [double]$f.used_percentage, (GioReset $f.resets_at $false))
      if ([double]$f.used_percentage -ge 90) { $canhBao = $true }
    }
    if ($w -and $null -ne $w.used_percentage) {
      $phan += ('7d {0:0}%' -f [double]$w.used_percentage)
      if ([double]$w.used_percentage -ge 90) { $canhBao = $true }
    }
    # Ghi lại cho 'xem usage' (ghi file tạm rồi thay, để không ai đọc phải file dở)
    $dir = Join-Path (Split-Path -Parent $PSScriptRoot) 'usage'
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $ban = [ordered]@{
      tk = $Tk
      five_hour = if ($f) { [ordered]@{ used_percentage = $f.used_percentage; resets_at = $f.resets_at } } else { $null }
      seven_day = if ($w) { [ordered]@{ used_percentage = $w.used_percentage; resets_at = $w.resets_at } } else { $null }
      cap_nhat = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    }
    $dich = Join-Path $dir "tk$Tk.json"
    $tam = "$dich.$PID.tmp"
    [IO.File]::WriteAllText($tam, ($ban | ConvertTo-Json -Depth 4), (New-Object Text.UTF8Encoding $false))
    Move-Item -LiteralPath $tam -Destination $dich -Force
  }
  $ctx = $j.context_window.used_percentage
  if ($null -ne $ctx) { $phan += ('ngữ cảnh {0:0}%' -f [double]$ctx) }
  $dong = $phan -join ' · '
  if ($canhBao) { $dong += ' · ⚠ sắp hết, gõ: bàn giao' }
  [Console]::Out.Write($dong)
} catch {
  [Console]::Out.Write($nhan)
}
