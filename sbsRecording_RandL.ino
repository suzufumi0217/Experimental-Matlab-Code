/****************************************************************
   Example2_Advanced.ino
   ICM 20948 Arduino Library Demo
   Shows how to use granular configuration of the ICM 20948
   Owen Lyke @ SparkFun Electronics
   Original Creation Date: April 17 2019

   This code is beerware; if you see me (or any other SparkFun employee) at the
   local, and you've found our code helpful, please buy us a round!

   Distributed as-is; no warranty is given.
 ***************************************************************/
#include "ICM_20948.h"  // Click here to get the library: http://librarymanager/All#SparkFun_ICM_20948_IMU
#include "MsTimer2.h"

//SPIを今回は使ってない
#define INT_PIN 7
//#define USE_SPI       // Uncomment this to use SPI


#define SERIAL_PORT Serial

#define SPI_PORT SPI    // Your desired SPI port.       Used only when "USE_SPI" is defined
#define SPI_FREQ 10000000// You can override the default SPI frequency
#define CS_PIN 2        // Which pin you connect CS to. Used only when "USE_SPI" is defined

#define WIRE_PORT Wire  // Your desired Wire port.      Used when "USE_SPI" is not defined
#define ADleft_VAL   0 //ここが重要，I2CのアドレスをそれぞれのIMUにふってる．
#define ADright_VAL   1
// The value of the last bit of the I2C address.
// On the SparkFun 9DoF IMU breakout the default is 1, and when
// the ADR jumper is closed the value becomes 0

#ifdef USE_SPI
ICM_20948_SPI myICM_right;  // If using SPI create an ICM_20948_SPI object
#else
ICM_20948_I2C myICM_right;  // Otherwise create an ICM_20948_I2C object
#endif

#ifdef USE_SPI
ICM_20948_SPI myICM_left;  // If using SPI create an ICM_20948_SPI object
#else
ICM_20948_I2C myICM_left;  // Otherwise create an ICM_20948_I2C object
#endif
//#define numOfThresholds 3

int i = 0;
int num_thresholds = 0;
int num_time = 0;
int trial_count = 0;
int prev_state = 0;
int current_state = 0;
float prev_w_hip, current_w_hip, prev_aa_hip, current_aa_hip, prev_time, current_time, start_time, time_for_output;
float time_stamp1 = 0.0;
float time_stamp2 = 0.0;
float time_stamp3 = 0.0;
float time_stamp4 = 0.0;
float calibration_time_sec = 0;
int detection_steps = 0;

bool isHigh = true;
volatile bool isRecording = false;
volatile bool isMainRight = false;  //MainLegが左右どちらかを表す．bool変数を用意．
volatile bool isMainLeft = false;
volatile bool isDetection = false;
volatile bool isDetected = false;
volatile bool isReceivedTime = false;
volatile bool isCalibration = false;
//volatile bool isStart = false;
volatile bool isRecievedD_param = false;
volatile bool isRecievedRorL = false;

int fsrAnalogPin_right = 0; // FSR0 is connected to analog 0
int fsrAnalogPin_left = 5; // FSR1 is connected to analog 1
int Rightheelstrike = 0;
int Leftheelstrike = 0;

int fsr_Right, fsr_Left;
int step_count = 0;

//変数を設定する
int R_prev_state = 0;
int R_current_state = 3;
float R_current_w_hip, R_prev_w_hip;
//R_current_w_hip = 0;
float R_current_aa_hip = 0, R_prev_aa_hip;
float R_current_FS, R_current_FS_original;


//変数を設定する
int L_prev_state = 0;
int L_current_state = 3;
float L_current_w_hip, L_prev_w_hip;
//L_current_w_hip = 0;
float L_current_aa_hip = 0, L_prev_aa_hip;
float L_current_FS, L_current_FS_original;

float thresholds_R_max,
      thresholds_L_max,
      thresholds_FS;

//calibration
String sign;
char charTime[20], charD_param[120];

//Detection
String RorL;
float step_duration, step_start_time, max_step_duration;
volatile bool isfinishstep = false;

//Updating
volatile bool isRecievedNewD_param = false;

void isflag() {
  if (isCalibration) {
    isRecording = true;
  } else if (isDetection) {
    isDetected = true;
  }
}

void setup() {
  pinMode(INT_PIN, OUTPUT);
  SERIAL_PORT.begin(115200);
  while (!SERIAL_PORT) {};

#ifdef USE_SPI
  SPI_PORT.begin();
#else
  WIRE_PORT.begin();
  WIRE_PORT.setClock(400000);
#endif

  bool initialized = false;
  while ( !initialized ) {
    //右のIMUを設定
#ifdef USE_SPI
    myICM_right.begin( CS_PIN, SPI_PORT, SPI_FREQ ); // Here we are using the user-defined SPI_FREQ as the clock speed of the SPI bus
#else
    myICM_right.begin( WIRE_PORT, ADright_VAL );
#endif

    //左のIMUを設定
#ifdef USE_SPI
    myICM_left.begin( CS_PIN, SPI_PORT, SPI_FREQ ); // Here we are using the user-defined SPI_FREQ as the clock speed of the SPI bus
#else
    myICM_left.begin( WIRE_PORT, ADleft_VAL );
#endif

    SERIAL_PORT.print( F("Initialization of the sensor returned: ") );
    SERIAL_PORT.println( myICM_right.statusString() );
    SERIAL_PORT.println( myICM_left.statusString() );
    if ( myICM_right.status != ICM_20948_Stat_Ok || myICM_left.status != ICM_20948_Stat_Ok) {
      SERIAL_PORT.println( "Trying again..." );
      delay(500);
    } else {
      initialized = true;
    }
  }

  // In this advanced example we'll cover how to do a more fine-grained setup of your sensor
  SERIAL_PORT.println("Device connected!");

  // Here we are doing a SW reset to make sure the device starts in a known state
  myICM_right.swReset( );
  myICM_left.swReset( );
  if ( myICM_right.status != ICM_20948_Stat_Ok || myICM_left.status != ICM_20948_Stat_Ok) {
    SERIAL_PORT.print(F("Software Reset returned: "));
    SERIAL_PORT.println(myICM_right.statusString());
    SERIAL_PORT.println(myICM_left.statusString());
  }
  delay(250);

  // Now wake the sensor up
  myICM_right.sleep( false );
  myICM_right.lowPower( false );
  myICM_left.sleep( false );
  myICM_left.lowPower( false );

  // The next few configuration functions accept a bit-mask of sensors for which the settings should be applied.

  // Set Gyro and Accelerometer to a particular sample mode
  // options: ICM_20948_Sample_Mode_Continuous
  //          ICM_20948_Sample_Mode_Cycled
  myICM_right.setSampleMode( (ICM_20948_Internal_Acc | ICM_20948_Internal_Gyr), ICM_20948_Sample_Mode_Continuous );
  if ( myICM_right.status != ICM_20948_Stat_Ok) {
    SERIAL_PORT.print(F("setSampleMode returned: "));
    SERIAL_PORT.println(myICM_right.statusString());
  }

  myICM_left.setSampleMode( (ICM_20948_Internal_Acc | ICM_20948_Internal_Gyr), ICM_20948_Sample_Mode_Continuous );
  if ( myICM_left.status != ICM_20948_Stat_Ok) {
    SERIAL_PORT.print(F("setSampleMode returned: "));
    SERIAL_PORT.println(myICM_left.statusString());
  }

  // Set full scale ranges for both acc and gyr
  ICM_20948_fss_t myFSS;  // This uses a "Full Scale Settings" structure that can contain values for all configurable sensors

  myFSS.a = gpm2;         // (ICM_20948_ACCEL_CONFIG_FS_SEL_e)
  // gpm2
  // gpm4
  // gpm8
  // gpm16

  myFSS.g = dps1000;       // (ICM_20948_GYRO_CONFIG_1_FS_SEL_e)
  // dps250
  // dps500
  // dps1000
  // dps2000

  myICM_right.setFullScale( (ICM_20948_Internal_Acc | ICM_20948_Internal_Gyr), myFSS );
  if ( myICM_right.status != ICM_20948_Stat_Ok) {
    SERIAL_PORT.print(F("setFullScale returned: "));
    SERIAL_PORT.println(myICM_right.statusString());
  }

  myICM_left.setFullScale( (ICM_20948_Internal_Acc | ICM_20948_Internal_Gyr), myFSS );
  if ( myICM_left.status != ICM_20948_Stat_Ok) {
    SERIAL_PORT.print(F("setFullScale returned: "));
    SERIAL_PORT.println(myICM_left.statusString());
  }


  // Set up Digital Low-Pass Filter configuration
  ICM_20948_dlpcfg_t myDLPcfg;            // Similar to FSS, this uses a configuration structure for the desired sensors
  myDLPcfg.a = acc_d23bw9_n34bw4;         // (ICM_20948_ACCEL_CONFIG_DLPCFG_e)
  // acc_d246bw_n265bw      - means 3db bandwidth is 246 hz and nyquist bandwidth is 265 hz
  // acc_d111bw4_n136bw
  // acc_d50bw4_n68bw8
  // acc_d23bw9_n34bw4
  // acc_d11bw5_n17bw
  // acc_d5bw7_n8bw3        - means 3 db bandwidth is 5.7 hz and nyquist bandwidth is 8.3 hz
  // acc_d473bw_n499bw

  myDLPcfg.g = gyr_d23bw9_n35bw9;       // (ICM_20948_GYRO_CONFIG_1_DLPCFG_e)
  // gyr_d196bw6_n229bw8
  // gyr_d151bw8_n187bw6
  // gyr_d119bw5_n154bw3
  // gyr_d51bw2_n73bw3
  // gyr_d23bw9_n35bw9
  // gyr_d11bw6_n17bw8
  // gyr_d5bw7_n8bw9
  // gyr_d361bw4_n376bw5

  myICM_right.setDLPFcfg( (ICM_20948_Internal_Acc | ICM_20948_Internal_Gyr), myDLPcfg );
  if ( myICM_right.status != ICM_20948_Stat_Ok) {
    SERIAL_PORT.print(F("setDLPcfg returned: "));
    SERIAL_PORT.println(myICM_right.statusString());
  }

  myICM_left.setDLPFcfg( (ICM_20948_Internal_Acc | ICM_20948_Internal_Gyr), myDLPcfg );
  if ( myICM_left.status != ICM_20948_Stat_Ok) {
    SERIAL_PORT.print(F("setDLPcfg returned: "));
    SERIAL_PORT.println(myICM_left.statusString());
  }

  // Choose whether or not to use DLPF
  // Here we're also showing another way to access the status values, and that it is OK to supply individual sensor masks to these functions
  ICM_20948_Status_e accDLPEnableStat_right = myICM_right.enableDLPF( ICM_20948_Internal_Acc, true );
  ICM_20948_Status_e gyrDLPEnableStat_right = myICM_right.enableDLPF( ICM_20948_Internal_Gyr, true );
  SERIAL_PORT.print(F("Enable DLPF for Accelerometer returned: ")); SERIAL_PORT.println(myICM_right.statusString(accDLPEnableStat_right));
  SERIAL_PORT.print(F("Enable DLPF for Gyroscope returned: ")); SERIAL_PORT.println(myICM_right.statusString(gyrDLPEnableStat_right));

  ICM_20948_Status_e accDLPEnableStat_left = myICM_left.enableDLPF( ICM_20948_Internal_Acc, true );
  ICM_20948_Status_e gyrDLPEnableStat_left = myICM_left.enableDLPF( ICM_20948_Internal_Gyr, true );
  SERIAL_PORT.print(F("Enable DLPF for Accelerometer returned: ")); SERIAL_PORT.println(myICM_left.statusString(accDLPEnableStat_left));
  SERIAL_PORT.print(F("Enable DLPF for Gyroscope returned: ")); SERIAL_PORT.println(myICM_left.statusString(gyrDLPEnableStat_left));

  ICM_20948_smplrt_t mySmplrt;
  mySmplrt.g = 10;
  mySmplrt.a = 10;
  myICM_right.setSampleRate( (ICM_20948_Internal_Acc | ICM_20948_Internal_Gyr), mySmplrt );
  myICM_left.setSampleRate( (ICM_20948_Internal_Acc | ICM_20948_Internal_Gyr), mySmplrt );
  SERIAL_PORT.print(F("setSampleRate returned: "));
  SERIAL_PORT.println(myICM_right.statusString());
  SERIAL_PORT.println(myICM_left.statusString());
  SERIAL_PORT.println();
  SERIAL_PORT.println(F("Configuration complete!"));
  MsTimer2::set(10, isflag); //10msごとにisflagを呼び出している．
  MsTimer2::start();
}

void loop() {
  if (SERIAL_PORT.available() > 0) { // キー入力待ち
    sign = SERIAL_PORT.readStringUntil('\r');//文字取り出す
    if (sign == "c") {
      while (!isReceivedTime) {
        if (SERIAL_PORT.available() > 0) {
          charTime[num_time] = SERIAL_PORT.read();
          if (charTime[num_time] == '\r') {
            charTime[num_time] = '\0';
            calibration_time_sec = atof(charTime);
            isReceivedTime = true;
            num_time = 0;
          } else {
            num_time += 1;
          }
        }
      }
      SERIAL_PORT.println("start calibration");
      isCalibration = true;
      SERIAL_PORT.print("Time,");
      SERIAL_PORT.print("Right_w_hip,");
      SERIAL_PORT.print("Left_w_hip,");
      SERIAL_PORT.print("Right_FS,");
      SERIAL_PORT.println("Left_FS");
      start_time = millis();
    } else if (sign == "d") {
      while (!isRecievedD_param) {
        if (SERIAL_PORT.available() > 0) {
          charD_param[num_thresholds] = SERIAL_PORT.read();
          if (charD_param[num_thresholds] == '\r') {
            charD_param[num_thresholds] == '\0';
            //matlabからthresholdsを受け取って，代入する
            thresholds_R_max = atof(strtok(charD_param, ","));
            thresholds_L_max = atof(strtok(NULL, ","));
            thresholds_FS = atof(strtok(NULL, ","));
            detection_steps = atof(strtok(NULL, ","));
            max_step_duration = atof(strtok(NULL, ","));
            isRecievedD_param = true;
            SERIAL_PORT.println("Complete recieving D_params");
            SERIAL_PORT.println();
            num_thresholds = 0;
          } else {
            num_thresholds += 1;
          }
        }
      }
      isDetection = true;
      SERIAL_PORT.println("start detection");
      start_time = millis();
      digitalWrite(INT_PIN, isHigh); //接続機器に対して，５Vを発することで同期を行っている．
    } else if (sign == "u") {
      while (!isRecievedNewD_param) {
        if (SERIAL_PORT.available() > 0) {
          charD_param[num_thresholds] = SERIAL_PORT.read();
          if (charD_param[num_thresholds] == '\r') {
            charD_param[num_thresholds] == '\0';
            //matlabからthresholdsを受け取って，代入する
            thresholds_R_max = atof(strtok(charD_param, ","));
            thresholds_L_max = atof(strtok(NULL, ","));
            thresholds_FS = atof(strtok(NULL, ","));
            detection_steps = atof(strtok(NULL, ","));
            max_step_duration = atof(strtok(NULL, ","));
            isRecievedNewD_param = true;
            SERIAL_PORT.println("Complete recieving new D_params");
            SERIAL_PORT.println();
            num_thresholds = 0;
          } else {
            num_thresholds += 1;
          }
        }
      }
      isDetection = true;
      SERIAL_PORT.println("Restart detection");
      start_time = millis();
      digitalWrite(INT_PIN, isHigh); //接続機器に対して，５Vを発することで同期を行っている．
    }
  }
  if (isRecording) {
    if ( myICM_right.dataReady() && myICM_left.dataReady()) {

      myICM_right.getAGMT();                // The values are only updated when you call 'getAGMT'
      myICM_left.getAGMT();

      //Footswitches get data
      fsr_Right = analogRead(fsrAnalogPin_right);
      fsr_Left = analogRead(fsrAnalogPin_left);
      R_current_FS_original = fsr_Right ;
      L_current_FS_original = fsr_Left ;

      R_current_FS = (R_current_FS_original / 1024 - 0.65) * 5;
      L_current_FS = (L_current_FS_original / 1024 - 0.64) * 25;

      //変数に取得したデータを代入している

      R_prev_w_hip = R_current_w_hip;
      R_current_w_hip = myICM_right.gyrZ();

      //変数に取得したデータを代入している
      L_prev_w_hip = L_current_w_hip;
      L_current_w_hip = - myICM_left.gyrZ();
      current_time = millis();
      time_for_output = (current_time - start_time) / 1000.00;
      SERIAL_PORT.print(time_for_output, 3);
      SERIAL_PORT.print(",");
      SERIAL_PORT.print(R_current_w_hip, 3);
      SERIAL_PORT.print(",");
      SERIAL_PORT.print(L_current_w_hip, 3);
      SERIAL_PORT.print(",");
      SERIAL_PORT.print(R_current_FS, 3);
      SERIAL_PORT.print(",");
      SERIAL_PORT.println(L_current_FS, 3);
      isRecording = false;
      if (time_for_output > calibration_time_sec) {
        SERIAL_PORT.println("Finish calibration");
        isCalibration = false;
        //        isStart = false;
        isReceivedTime  = false;
      }
    }
    else {
      SERIAL_PORT.println("Waiting");
      delay(100);
    }
  } else if (isDetected) {
    while (!isRecievedRorL) {
      if (SERIAL_PORT.available() > 0) { //キー入力待ち
        RorL = SERIAL_PORT.readStringUntil('\r');//文字取り出す
        if (RorL == "r") {
          //mainleg をrightとする
          isMainRight = true;
          R_current_state = 3;
          step_start_time = millis();
          isRecievedRorL = true;
        } else if (RorL == "l") {
          //mainlegをleftとする
          isMainLeft = true;
          L_current_state = 3;
          step_start_time = millis();
          isRecievedRorL = true;
        } else if (RorL == "e") {
          isDetection = false;
          isDetected = false;
          isRecievedRorL = true;
          isfinishstep = false;
          SERIAL_PORT.println("End Detection");
        }
      }
    }
    if ( myICM_right.dataReady() && myICM_left.dataReady()) {
      myICM_right.getAGMT();                // The values are only updated when you call 'getAGMT'
      myICM_left.getAGMT();

      //Footswitches get data
      fsr_Right = analogRead(fsrAnalogPin_right);
      fsr_Left = analogRead(fsrAnalogPin_left);
      R_current_FS_original = fsr_Right ;
      L_current_FS_original = fsr_Left ;

      if (isMainRight) {
        //変数に取得したデータを代入している
        R_current_FS = (R_current_FS_original / 1024 - 0.65) * 5;
        R_prev_state = R_current_state;
        R_prev_w_hip = R_current_w_hip;
        R_prev_aa_hip = R_current_aa_hip;
        R_current_w_hip = myICM_right.gyrZ();
        R_current_aa_hip = R_current_w_hip - R_prev_w_hip;

        //Detect StateChange
        if (R_prev_state == 3) {
          if ((R_prev_w_hip >= thresholds_R_max) && R_current_aa_hip <= 0 && R_prev_aa_hip >= 0 && R_current_FS < thresholds_FS) {
            R_current_state = 4;
          }
        }
        else if (R_prev_state == 1) {
          if (  R_current_FS > thresholds_FS ) {
            R_current_state = 2;
          }
        }
        else if (R_prev_state == 4) {
          if (R_prev_w_hip > 0 && R_current_w_hip <= 0) {
            R_current_state = 1;
          }
        }
        else if (R_prev_state == 2) {
          isMainRight = false;
          isRecievedRorL = false;
          isfinishstep = true;//isfinishstepとか書いて下のprintに入らない様にするわ．
          step_count += 1;
        }
        //matlabに送信する
        current_time = millis();
        step_duration = (current_time - step_start_time) / 1000.00;
        time_for_output = (current_time - start_time) / 1000.00;
        if (!isfinishstep) {
          SERIAL_PORT.print(step_duration, 3);
          SERIAL_PORT.print(",");
          SERIAL_PORT.print(R_current_state);
          SERIAL_PORT.print(",");
          SERIAL_PORT.print(R_current_FS);
          SERIAL_PORT.print(",");
          SERIAL_PORT.println(R_current_w_hip);
        } else {
          SERIAL_PORT.println("Finish Step");
          isfinishstep = false;
        }

      } else if (isMainLeft) {

        //変数に取得したデータを代入している
        L_current_FS = (L_current_FS_original / 1024 - 0.64) * 25;
        L_prev_state = L_current_state;
        L_prev_w_hip = L_current_w_hip;
        L_prev_aa_hip = L_current_aa_hip;
        L_current_w_hip = - myICM_left.gyrZ();
        L_current_aa_hip = L_current_w_hip - L_prev_w_hip;

        //Detect StateChange
        if (L_prev_state == 3) {
          if ((L_prev_w_hip >= thresholds_L_max) && L_current_aa_hip <= 0 && L_prev_aa_hip >= 0 && L_current_FS < thresholds_FS) {
            L_current_state = 4;
          }
        }
        else if (L_prev_state == 1) {
          if (  L_current_FS > thresholds_FS ) {
            L_current_state = 2;

          }
        }
        else if (L_prev_state == 4) {
          if (L_prev_w_hip > 0 && L_current_w_hip <= 0) {
            L_current_state = 1;
          }
        }
        else if (L_prev_state == 2) {
          isMainLeft = false;
          isRecievedRorL = false;
          isfinishstep = true;
          step_count += 1;
        }
        //データをmatlabに送信する
        current_time = millis();
        step_duration = (current_time - step_start_time) / 1000.00;
        time_for_output = (current_time - start_time) / 1000.00;
        if (!isfinishstep) {
          SERIAL_PORT.print(step_duration, 3);
          SERIAL_PORT.print(",");
          SERIAL_PORT.print(L_current_state);
          SERIAL_PORT.print(",");
          SERIAL_PORT.print(L_current_FS);
          SERIAL_PORT.print(",");
          SERIAL_PORT.println(L_current_w_hip);
        }else{
          SERIAL_PORT.println("Finish Step");
          isfinishstep = false;
        }

      }
      isDetected = false;
    } else {
      SERIAL_PORT.println("Waiting");
      delay(100);
    }

    if (step_count >= detection_steps) {
      SERIAL_PORT.println("Finish section");
      isDetection = false;
      isDetected = false;
      isRecievedD_param = false;
      isRecievedRorL = false;
      digitalWrite(INT_PIN, !isHigh);
    } else if (step_duration >= max_step_duration) {
      isRecievedRorL = false;
      isMainRight = false;
      isMainLeft = false;
      SERIAL_PORT.println("Finish Step");
    }
  }

}
