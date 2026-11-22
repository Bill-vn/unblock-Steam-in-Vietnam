Set sh = CreateObject("WScript.Shell")
sh.CurrentDirectory = "C:\steam-tunnel"
sh.Run """C:\steam-tunnel\bin\sing-box.exe"" run -c ""C:\steam-tunnel\config.json""", 0, False
