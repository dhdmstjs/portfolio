import processing.net.*; 
import processing.serial.*;
import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle;
import processing.sound.*;

SoundFile correctFace1;
SoundFile incorrectFace1;
SoundFile incorrectFace2;
SoundFile incorrectFace3;
SoundFile incorrectFace4;
SoundFile samFace;
SoundFile searching;
SoundFile wakeUp1;
SoundFile wakeUp2;



//initiate the client, capture  and serial objects
OpenCV opencv;
Client myClient;
Capture cam;
Rectangle[] faces;




String file = "C:\\Users\\Main Character\\Desktop\\mirror\\pictures\\temp\\pic.jpg";
int newMessage;
int pictureFlag;
//this string will be used as a sort of buffer for processing to designate
//where it stored the file to
int newFile = 0;
int message = 0;
int state = 0;


void setup() { 
  size(640, 480); 
  //import all sound files
  correctFace1 = new SoundFile(this, "correctFace1.wav");
  incorrectFace1 = new SoundFile(this, "incorrectFace1.wav");
  incorrectFace2 = new SoundFile(this, "incorrectFace2.wav");
  incorrectFace3 = new SoundFile(this, "incorrectFace3.wav");
  incorrectFace4 = new SoundFile(this, "incorrectFace4.wav");
  samFace = new SoundFile(this, "samFace.wav");
  searching = new SoundFile(this, "searching.wav");
  wakeUp1 = new SoundFile(this, "wakeUp1.wav");
  wakeUp2 = new SoundFile(this, "wakeUp2.wav");
  //initialize the client on home ip with same port as python server 
  //(the port is arbitrary, just has to be the same as the server)
  myClient = new Client(this, "127.0.0.1", 5555); 
  //setup communication to arduino
  //setup webcam to take frames from stream
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this, "Logitech Webcam C930e,size=640x480,fps=30");
    cam.start(); 
    cam.read();
  }
} 

void draw() { 
  //read the camera stream and display that in the window
  if (cam.available() == true) {
    cam.read();
    //opencv = new OpenCV(this,"test.jpg");
    //opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
    //faces = opencv.detect();

  }
//  image(cam,0,0);
  set(0, 0, cam);

  //check the client is active. Then check if the string value has been changed
  //if the string value has been changed, send that value to the python server
  //then reset the string value to empty

  //return server output after it has processed the file
  //*TO DO*: handle dropped client connections 
  if (myClient.active()) {
    if (message == 1) {
      myClient.write("state1");
      message = 0;
    }  
    if(message == 2){
      myClient.write(file);
      message = 0;
    }
    String cur = myClient.readString();
    if (cur != null) {
      newMessage = 1;
      pictureFlag = int(cur);
      println(cur);
    }
  }

  if (newMessage == 1) {
    if (pictureFlag == 1) {

      
      correctFace1.play();
      println("Welcome Sam");
    } else {
      incorrectFace1.play();
      println("You are not Sam");
      //if(myPort.available())
    }
    state = 0;
    newMessage = 0;
    pictureFlag = 0;
  }
//  println(frameCount);
} 

void mouseClicked() {
  if(state==1){
    state = 2;
    cam.stop();
    saveFrame(file);
    //newFile = 1;
    cam.start();
    message = 2;
    searching.play();
    delay(1500);
  }
}

void keyPressed(){
  if(key == 'w'){
    if(state==0){
      state=1;
      wakeUp1.play();
      delay(11000);
    }
  }
}