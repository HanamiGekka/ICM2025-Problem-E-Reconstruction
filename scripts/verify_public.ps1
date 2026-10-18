param([Parameter(Mandatory=$true)][string]$GitExe,[switch]$BeforeCommit,[string[]]$PrivateTerms=@(),[string]$ExpectedOrigin='')
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$allowed=@((Import-Csv -LiteralPath (Join-Path $root 'release_whitelist.csv')).Path)
if($allowed.Count -ne @($allowed | Sort-Object -Unique).Count){throw 'Duplicate whitelist entries'}
$forbidden='^(Original|demand|temp|\.work|docs/audit|docs/development)(/|$)|\.(pdf|docx|zip|fig|mat|exe|dll|pfx|pem)$'
$sensitive='(?<![A-Za-z0-9])[A-Za-z]:[\\/]|[\p{IsCJKUnifiedIdeographs}]|(?<![A-Za-z0-9.])1[3-9][0-9]{9}(?![A-Za-z0-9.])|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}|(?:sk-|ghp_|github_pat_)[A-Za-z0-9_]{16,}'
$sensitive+='|'+('-----'+'BEGIN .*PRIVATE KEY'+'-----')
$extensions=@('.md','.m','.ps1','.csv','.json','.png','.gitignore','.py','.yml','')
# Natural-language content is reviewed only in these four README entry points.
$localizedReadmes=@('README.md','README.zh-CN.md','README.ja.md','README.zh-TW.md')
# Explicit user-authorized historical copies; never a whole-directory exception.
$authorizedDocuments=@{
 'historical-documents/competition-paper.pdf'='3F3E6D2F76A29596644AD8932BD6CB987D74CA5B871A082233AC3B70F361F808'
 'historical-documents/award-certificate.pdf'='EDDB8D05B0AEEAF593566641E6CFB4DFDE9DCCB9B7FDE374EE7220B4002F8556'
}
function CheckFile([string]$path,[byte[]]$bytes){
 if($authorizedDocuments.ContainsKey($path)){
  if($path -notin $allowed){throw 'Authorized document absent from whitelist'}
  $sha=[Security.Cryptography.SHA256]::Create()
  try{$hash=[BitConverter]::ToString($sha.ComputeHash($bytes)).Replace('-','')}finally{$sha.Dispose()}
  if($hash -ne $authorizedDocuments[$path]){throw "Historical document bytes changed: $path"}
  return # Names/award signatures/document metadata explicitly authorized only here.
 }
 if($path -notin $allowed -or $path -match $forbidden){throw "Excluded/unreviewed public path: $path"}
 $extension=[IO.Path]::GetExtension($path)
 if($extension -notin $extensions){throw "Unreviewed file type: $path"}
 if($extension -eq '.png'){
  if($bytes.Length -lt 8 -or $bytes[0] -ne 137 -or $bytes[1] -ne 80){throw "Invalid PNG: $path"}
  # Scan structured textual metadata, not random compressed pixel bytes.
  $position=8; $text=''
  while($position+12 -le $bytes.Length){
   $length=[long]$bytes[$position]*16777216+[long]$bytes[$position+1]*65536+[long]$bytes[$position+2]*256+$bytes[$position+3]
   if($position+12+$length -gt $bytes.Length){throw 'Malformed PNG chunk'}
   $type=[Text.Encoding]::ASCII.GetString($bytes,$position+4,4)
   if($type -in @('zTXt','eXIf')){throw "Compressed/EXIF metadata requires review: $path"}
   if($type -in @('tEXt','iTXt')){
    $payload=$bytes[($position+8)..($position+7+$length)]
    if($type -eq 'iTXt'){
     $zero=[Array]::IndexOf($payload,[byte]0)
     if($zero -lt 0 -or $payload[$zero+1] -ne 0){throw 'Compressed/invalid PNG text requires review'}
    }
    $text+=[Text.Encoding]::UTF8.GetString($payload)+"`n"
   }
   $position+=12+$length
  }
 } else {$text=[Text.Encoding]::UTF8.GetString($bytes)}
 $contentSensitive=$sensitive
 if($path -in $localizedReadmes){$contentSensitive=$contentSensitive.Replace('[\p{IsCJKUnifiedIdeographs}]|','')}
 if($text -match $contentSensitive){throw "Potential private identifier/path/credential in: $path"}
 foreach($term in $PrivateTerms){if($text -match ('(?<![A-Za-z0-9.])'+[regex]::Escape($term)+'(?![A-Za-z0-9])')){throw "Known private identifier in: $path"}}
}
function ReadGitBlob([string]$revision,[string]$path){
 if($revision -notmatch '^[0-9a-f]+$' -or $path -notmatch '^[A-Za-z0-9_./-]+$'){throw 'Unexpected history path'}
 $start=New-Object Diagnostics.ProcessStartInfo
 $start.FileName=$GitExe; $start.Arguments='show '+$revision+':'+$path
 $start.WorkingDirectory=$root; $start.UseShellExecute=$false
 $start.CreateNoWindow=$true; $start.RedirectStandardOutput=$true; $start.RedirectStandardError=$true
 $process=New-Object Diagnostics.Process; $process.StartInfo=$start
 $memory=New-Object IO.MemoryStream
 try{
  $null=$process.Start(); $process.StandardOutput.BaseStream.CopyTo($memory)
  $errorText=$process.StandardError.ReadToEnd(); $process.WaitForExit()
  if($process.ExitCode -ne 0){throw $errorText}; return ,$memory.ToArray()
 }finally{$memory.Dispose();$process.Dispose()}
}
foreach($private in @('Original','demand','temp','docs/audit','docs/development')){
 if(Test-Path -LiteralPath (Join-Path $root $private)){throw "Private directory present: $private"}
}
$files=@(Get-ChildItem -LiteralPath $root -Recurse -File -Force | Where-Object {
 !$_.FullName.Equals((Join-Path $root '.git'),[StringComparison]::OrdinalIgnoreCase) -and
 !$_.FullName.StartsWith((Join-Path $root '.git')+'\') -and !$_.FullName.StartsWith((Join-Path $root '.work')+'\')
})
$paths=@()
foreach($file in $files){
 if($file.Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Reparse point in public tree'}
 $path=$file.FullName.Substring($root.Length+1).Replace('\','/'); $paths+=$path
 CheckFile $path ([IO.File]::ReadAllBytes($file.FullName))
}
if(@(Compare-Object ($allowed | Sort-Object) ($paths | Sort-Object)).Count){throw 'Workspace differs from explicit whitelist'}
Push-Location $root
try{
 $remote=@(& $GitExe remote)
 if($remote.Count){
  if($remote.Count -ne 1 -or $remote[0] -ne 'origin' -or !$ExpectedOrigin){throw 'Supply explicitly reviewed origin'}
  $fetch=& $GitExe remote get-url origin; $push=& $GitExe remote get-url --push origin
  if($fetch -ne $ExpectedOrigin -or $push -ne $ExpectedOrigin){throw 'Origin differs from reviewed target'}
 }
 $tracked=@(& $GitExe ls-files)
 if(!$BeforeCommit -and @(Compare-Object ($allowed | Sort-Object) ($tracked | Sort-Object)).Count){throw 'Tracked files differ from whitelist'}
 $commits=@(& $GitExe rev-list --all)
 foreach($commit in $commits){
  $identity=& $GitExe show -s '--format=%an <%ae>|%cn <%ce>|%B' $commit
  $identity=$identity -replace 'Reconstruction Contributors <reconstruction@invalid>','REVIEWED_GENERIC_IDENTITY'
  if($identity -match $sensitive -or $identity -match '@'){throw 'Unreviewed public commit identity/message'}
  foreach($path in @(& $GitExe ls-tree -r --name-only $commit)){
   if($path -notin $allowed -or ($path -match $forbidden -and !$authorizedDocuments.ContainsKey($path))){throw "Excluded file in public history: $path"}
   CheckFile $path (ReadGitBlob $commit $path)
  }
 }
 if(!$BeforeCommit -and @(& $GitExe status --porcelain).Count){throw 'Public worktree not clean'}
 Write-Output "PUBLIC_SCAN_PASS whitelist=$($allowed.Count) commits=$($commits.Count); strict software/data scan; two hash-pinned user-authorized historical PDFs; reviewed origin"
} finally{Pop-Location}



