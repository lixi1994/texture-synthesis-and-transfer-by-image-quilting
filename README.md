# texture-synthesis-and-transfer-by-image-quilting

How to run:

This project is conducted in Matlab (2015b) and is based on the paper Image Quilting for Texture Synthesis and Transfer (Efros and Freeman 2001).
1. Enter the folder code/
2. In Matlab, run “demo.m”, you will get two synthesized textures generated by minimum cut and interpolation respectively and one transferred image.
3. Or in command window in Matlab, run synthesis (sample texture, texton, number of texton, ‘minimumcut’ or ‘interpolation’) 
or transfer (sample texture, target image, texton, iteration times).
4. The output texture is named as “sample texture-quilting method.jpg”, like “tomatoes-minimumcut.jpg”. Or it is named as “source texture-target image-transfer.jpg”.

Inputs:
Folder “sampleTextures” stores all the sample textures and their corresponding synthesized textures. Besides, there’re also textures and target images used for transfer in it.
