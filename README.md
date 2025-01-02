# wildermyth-stats-reroll

An AutoHotkey script to randomly reroll new characters in the game Wildermyth until a character with a desired set of stats is found. The script uses OCR to detect and filter each character's stats.

Change the desired stats by modifying the `DesiredStats` variable in roll.ahk. See e.g. commented code lines.

Important note: not all stat configurations exist in the game, and some configurations are only obtainable in certain campaigns. See e.g. https://wildermyth.com/wiki/Hero#Upbringing.

Usage: first, use F10 on the character creation screen to provide a screen rectangle where the character stats are displayed. Then, use F12 to start rolling for a character and F11 to stop the search.

This was developed for Wildermyth version 1.14+486 Elona Rib. I am not sure if this works in newer versions, but I see no reason why it wouldn't.