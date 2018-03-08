# -*- coding: utf-8 -*-
"""
Created on Thu May 11 15:39:30 2017

@author: Main Character
"""

import socket
from _thread import *
import kairos_face
import os

#store your api key and id below
kairos_face.settings.app_id = '50d0c8e2'
kairos_face.settings.app_key = '1517e15dc89de6b9a27de5bad83afe78'
#designate your host and port info
#the blank host info designates it will accept any host
host = ''
port = 5555
noted = False

#determine if this is first connection for the client
firstConnect = True

#create socket object s
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#attempt to bind the socket object to the designated host and port
#if there is a failure, print the error
try:
    s.bind((host,port))
except socket.error as e:
    print(str(e))
#listen for the processing client to connect to the server
s.listen(1)
print("waiting for a connection...")
   
#use the kairos api to take the file designated by the client and 
#compare it to the existing gallery in place
#return the verification value to denote similarity of the faces

def verify(filename,subject,gallery):
    recognized = kairos_face.verify_face(file=filename, 
                                           subject_id=subject,
                                           gallery_name=gallery)
    #print(recognized)
    confidence = recognized['images'][0]['transaction']['confidence']
    print(confidence)
    if(confidence > .85):
        return("1")
    else:
        return("0")


#function to handle the client and server interactions
def threaded_client(conn):
    #constantly check for information from the client side
    try: 
        while True:
            data = conn.recv(2048)
            message = (data.decode("utf-8"))
            #reply = ("Server: " + message)
            print(message)
            verificationVal = str(verify(message, "daniela", "gallery1"))
            if not data:
                break
            conn.sendall(str.encode(verificationVal))
        
    finally:
        conn.close()

while True:    
    conn, addr = s.accept()
    #on initiation notify the client they connected
    if(firstConnect):
        conn.send(str.encode("Server and client connected"))
        firstConnect = False
    while True:      
        #notify server side of connection info
        if(noted == False):
            print('connected to: ' + addr[0]+":"+str(addr[1]))
            noted = True
        data = conn.recv(2048)
        message = (data.decode("utf-8"))
        #reply = ("Server: " + message)
        print(message)
        verificationVal = str(verify(message, "daniela", "gallery1"))
        if not data:
            break
        conn.sendall(str.encode(verificationVal))
