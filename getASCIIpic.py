# encoding:utf-8

 #terminal: python getdat.py helloworld.png
from PIL import Image
import argparse

#命令行输入参数处理
parser = argparse.ArgumentParser()

parser.add_argument('file')     #输入文件
parser.add_argument('-o', '--output')   #输出文件
parser.add_argument('--width', type = int, default = 32 * 8) #输出字符画宽
parser.add_argument('--height', type = int, default = 256) #输出字符画高


# //这里要看图片像素，宽像素是多少，高像素是多少，不然不成比例
#获取参数
args = parser.parse_args()

IMG = args.file
WIDTH = args.width
HEIGHT = args.height
OUTPUT = args.output

# ascii_char = list("$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\|()1{}[]?-_+~<>i!lI;:,\"^`'. ")
ascii_char = list("01")

# 将256灰度映射到70个字符上
def get_char(r,g,b,alpha = 256):
    if alpha == 0:
        return ' '
    length = len(ascii_char)
    gray = int(0.2126 * r + 0.7152 * g + 0.0722 * b)

    unit = (256.0 + 1)/length
    return ascii_char[int(gray/unit)]

if __name__ == '__main__':

    im = Image.open(IMG)
    im = im.resize((WIDTH,HEIGHT), Image.NEAREST)

    txt = ""

    for i in range(HEIGHT):
        for j in range(WIDTH):
            txt += get_char(*im.getpixel((j,i)))
        txt += '\n'

    print txt

    # 字符画输出到文件
    # if OUTPUT:
    #     with open(OUTPUT,'w') as f:
    #         f.write(txt)
    # else:
    #     with open("output.txt",'w') as f:
    #         f.write(txt)
    # 字符画输出到文件
    if OUTPUT:
        with open(OUTPUT,'w') as f:
            f.write(txt)
    else:
        with open("Memory32*8*256.txt",'w') as f:#二进制文件write binary
            f.write(txt)

# import numpy as np
# from PIL import Image
# import skimage.io
# img = Image.open("Woman.png")
# img = img.convert("L")
# imgs = skimage.io.imread("Woman.png")
# ttt = np.mean(imgs)
# WHITE, BLACK = 255, 0
# img = img.point(lambda x: WHITE if x > ttt else BLACK)
# img = img.convert('1')
# img.save("girl.jpg")
# text1 = "我爱你"
# texlength = len(text1)
# text2 = text1[2:texlength]
# #将long型和string保存到文件中
# WriteFileData = open("/home/curie/KerasBook/myverilog/test/getdat.dat",'wb')
# for i in range(0,2047):
#     WriteFileData.write(str(i));
# WriteFileData.close()
