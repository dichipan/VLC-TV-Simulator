# VLC-TV-Simulator
Lua extension for VLC that simulates watching television. Shows will be shuffled and played at random with 5-8 random commercials between each show. Shows and commercials must be provided by yourself.

# INSTALL
1. In the file, set the directory for "shows_directory" and "commercials_directory" to their respective locations.
2. Place the file within the "...\VLC\lua\extensions\" directory.
3. Open VLC.
4. Click on View > Watch TV.

# NOTE
- If you want to change the number of commercials that play between episodes, change the parameters of "num_commercials" at line 122. I settled on 5-8 as that is the average number of commercials that plays between shows in USA.
- This project was created for myself and I am satisfied with where it is, I uploaded it on the off-chance someone may be looking for something similar. Chances are I will not update it, feel free to make and upload any changes.
