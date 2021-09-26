# fedora_mutter_fix

Script created for fix the lag/freeze issue with Gnome(Xorg Only).
The lag/freeze occurs when a key with different keyboard layout is pressed. Example: some keyboards have a volume scroll and this scroll have a different layout entry.
When the volume scroll is used the next key pressed makes the entire system to freeze for a second.

The problem is known by the gnome-shell community: https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/1858
But the team has a focus on Wayland and problably will not fix the Xorg problem.
This script is created based on @Wiggyboy and  @carlosg (Gnome Developer), guide and solution (both can be finded on GitLab)

Only tested in Fedora 34 right after the official release.
