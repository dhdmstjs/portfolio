# -*- coding: utf-8 -*-
"""
Created on Mon Mar 27 15:38:51 2017

@author: Main Character
"""
#helper methods for common ways to interact with the kairos api
#this file is used for managing galleries and subjects
###TO DO: improve user interaction for manipulating gallery info

import kairos_face
import os

kairos_face.settings.app_id = ''
kairos_face.settings.app_key = ''



def listGalleries():
    galleries_object = kairos_face.get_galleries_names_object()
    
    for gallery_name in galleries_object:
        gallery = kairos_face.get_gallery_object(gallery_name)
        print('Gallery name: {}'.format(gallery.name))
        print('Gallery subjects: {}'.format(gallery.subjects))
        
def removeSubject(subject, gallery):
    print("Removing " + subject + "from " + gallery + "...")
    kairos_face.remove_face(subject, gallery)
    print("Completed removing subject")
    
def removeGallery(gallery):
    print("Removing gallery: " + gallery + "...")
    kairos_face.remove_gallery(gallery)
    print("Completed removing gallery")
    
def enrollDir(directory, galleryName, subjectName):
    print("Enrolling pictures from the directory into the gallery...")
    acc = 1
    for file in os.listdir(directory):
        kairos_face.enroll_face(file=directory+subjectName+str(acc)+".jpg",
                                subject_id=subjectName,
                                gallery_name=galleryName)
        acc += 1
    
    print("Enrollment complete")

def verify(filename,subject,gallery):
    recognized = kairos_face.verify_face(file=filename, 
                                           subject_id=subject,
                                           gallery_name=gallery)
    #print(recognized)
    confidence = recognized['images'][0]['transaction']['confidence']
    print(confidence)
    if(confidence > .85):
        return True
    else:
        return False
    
enrollDir("pictures/marcus/", "gallery2", "marcus")
listGalleries()

#verify("pictures/other/paula.png", "daniela", "gallery1")
#verify("pictures/other/danielamom.jpg", "daniela", "gallery1")
 

   
