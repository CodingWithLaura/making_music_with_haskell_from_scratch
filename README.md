# making_music_with_haskell_from_scratch

First of all, a sinus wave needs to be created which represents the audio signal. The wave itself is a list of Floats wth samples from 0.0 to 48000.

Second of all, the wave has to be converted into a ByteString-format which allows to be properly handeled by ffplay.

For this, both libaries Data.ByteString.Lazy and Data.ByteString.Builder needs to be imported as namespaces B since they have functions which are also defined outside of the libaries e.g. map. You can then access the map function within the Data.ByteString libary by typing B.map.

To interpret the ByteString file to actual sound, I used the program ffplay. Its an audio/video output program for the command line. 
