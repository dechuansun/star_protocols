double light_on=2;
double light_off=3;
double sound_on=2;
double sound_off=3;
double extra_off=0.5;
double epoch_duration=2;
int sound_order[] = {4000,8000,16000,4000,4000,8000,16000}; //frequency 4khz,8khz,16khz
int light_sound_order[] = {1,2,3,4,1,3,2,1,4,2,4}; //1:light_on, sound_on; 2: light_off, sound_on; 3:light_on, sound_off; 4; light_off, sound_off;
int iteration=600,flag=0;
unsigned long tic,toc;
double extra_off_time=0;
void setup() {
 Serial.setTimeout(1);
 pinMode(13, OUTPUT); 
 pinMode(12, OUTPUT); 
 digitalWrite(12, LOW);
 digitalWrite(13, LOW);
 Serial.begin(115200);
}
void loop() {
 while (!Serial.available());
 flag = Serial.readString().toInt();

 if (flag == 1) {
  tic = millis();
  for(int i=0; i<iteration;i++)
  {
    digitalWrite(12, HIGH);
    while(millis()-tic<light_on*1000);
    tic=millis();
    digitalWrite(12, LOW);
    extra_off_time=random(0,extra_off*1000);
    while(millis()-tic<(light_off*1000+extra_off_time));
    tic=millis();
    Serial.print("1");
  }
} 
else if (flag == 2) {
    tic = millis();
  for(int i=0; i<iteration;i++)
  {
    tone(11, sound_order[i], sound_on*1000);
    tic=millis();
    digitalWrite(11, LOW);
    extra_off_time=random(0,extra_off*1000);
    while(millis()-tic<(sound_off*1000+extra_off_time));
    Serial.print(sound_order[i]);
  }
}
//1:light_on, sound_on; 2: light_off, sound_on; 3:light_on, sound_off; 4; light_off, sound_off;
else if (flag == 3) {
  tic = millis();
  for(int i=0; i<iteration;i++)
  {
    if (light_sound_order[i]==1)
    {
      tic = millis();
      digitalWrite(12, HIGH);
      tone(11, 4000, epoch_duration*1000);
      while(millis()-tic<epoch_duration*1000);
      digitalWrite(12, LOW);
    }
    else if(light_sound_order[i]==2)
    {
      tic = millis();
      digitalWrite(12, LOW);
      // tone(11, 4000, sound_on*1000);
      while(millis()-tic<epoch_duration*1000);
      digitalWrite(12, LOW);
    }
    else if(light_sound_order[i]==3)
    {
      tic = millis();
      digitalWrite(12, HIGH);
      tone(11, 4000, epoch_duration*1000);
      while(millis()-tic<epoch_duration*1000);
      digitalWrite(12, LOW);
    }    
    else if(light_sound_order[i]==4)
    {
      tic = millis();
      // digitalWrite(12, HIGH);
      // tone(11, 4000, epoch_duration*1000);
      while(millis()-tic<epoch_duration*1000);
      digitalWrite(12, LOW);
    }

    Serial.print(light_sound_order[i]);
  }
}
else{
  Serial.print("wrong");
}

}