# lazykatz
Lazykatz is an automation developed to extract credentials from remote targets protected with AV and/or application whitelisting software.

During an internal assessment, I came across a situation where I was unable to execute Mimikatz (plain, crypted, powershell, etc.) on target machines due to the AntiVirus + Application whitelisting software installed on them.

However, I was able to bypass these restrictions using @subtee (https://github.com/subTee/Utils/blob/master/katz.cs) method but for that I had to perform this attack on all the hosts manually which would take forever with ~1500 machines.

To overcome this, I developed a keystroke automation tool - Lazykatz which would perform this attack automatically on all provided hosts.

# Usage

https://youtu.be/SnlQ6Tz02D4

# Credits

@subtee, @autoIt, @bhdresh

# Disclaimer

This program is for Educational purpose ONLY. Do not use it without permission. The usual disclaimer applies, especially the fact that me (bhdresh) is not liable for any damages caused by direct or indirect use of the information or functionality provided by these programs. The author or any Internet provider bears NO responsibility for content or misuse of these programs or any derivatives thereof. By using this program you accept the fact that any damage (dataloss, system crash, system compromise, etc.) caused by the use of these programs is not bhdresh's responsibility.

# Bug, issues, feature requests

Obviously, I am not a fulltime developer so expect some hiccups

Please report bugs, issues, feature requests to bhdresh@gmail.com
