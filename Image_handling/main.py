# -*- coding: utf-8 -*-
"""
Created on Wed Dec 16 22:32:12 2020

@author: Berkay
"""
import serial
import numpy as np
import pytesseract            
import pyttsx3            
from googletrans import Translator   
from tkinter import *  
from PIL import ImageTk,Image  
import time


def binarize(pxl, threshold):
    if pxl > threshold:
        return 255
    else:
        return 0
  
#time.sleep(20)
    
ser = serial.Serial(port = 'COM6', baudrate = 460800, bytesize = serial.EIGHTBITS,
                     parity = serial.PARITY_NONE, timeout = 10)

try:
    ser.isOpen()
    print("Serial port is open")
except:
    print("error1")
    exit()



completed = False
data = np.zeros((240, 640), dtype=np.uint8)

if ser.isOpen():
    try:
        while not completed:
            if ord(ser.read()) != 1:
                for row in range(240):
                    for col in range(640):
                        #data[row, col] = binarize(ord(ser.read()), 70)
                        data[row, col] = ord(ser.read())
                completed = True        
            
    except Exception:
        print("Error2")
        
else:
    print("cannot open serial port")  
    
    
print(data)
data = data[: 240, : 320]
img = Image.fromarray(data , 'L')
img.save('my.png')
img = Image.open('my.png')    
                          

pytesseract.pytesseract.tesseract_cmd ='C:\\Program Files\\Tesseract-OCR\\tesseract.exe'   
result = pytesseract.image_to_string(img)    
 
with open('imageToText.txt',mode ='w') as file:      
                 file.write(result) 
                 print(result) 
    
"""
p = Translator()                       
k = p.translate(result, dest = 'german')       
print(k) 
"""

img.show() 


engine = pyttsx3.init() 
 
engine.say(result)             
                 
engine.runAndWait()
    
    
