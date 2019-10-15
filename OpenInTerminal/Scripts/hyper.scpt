tell application "Finder"
  set cwd to POSIX path of ((target of front Finder window) as text)
  do shell script "open -a Hyper " & quoted form of cwd
end tell
