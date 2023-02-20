

#include <Servo.h>

Servo servo_base;
Servo servo_left;
Servo servo_right;
Servo servo_claw;

int i = 0;
int inter_position;
#define TEST_BASE
#define TEST_LEFT
#define TEST_RIGHT
#define TEST_CLAW

#define DELAY (5)

#if defined TEST_BASE
// 底座
#define ARM_BASE_SERVO_MIN (10)
#define ARM_BASE_SERVO_MAX (179)
#define ARM_BASE_SERVO_PIN (11)
#endif

#if defined TEST_LEFT
// 左臂
#define ARM_LEFT_SERVO_MIN (10)
#define ARM_LEFT_SERVO_MAX (140)
#define ARM_LEFT_SERVO_PIN (10)
#endif

// 右臂
#if defined TEST_RIGHT
#define ARM_RIGHT_SERVO_MIN (40)
#define ARM_RIGHT_SERVO_MAX (170)
#define ARM_RIGHT_SERVO_PIN (9)
#endif

#if defined TEST_CLAW
// 爪子
#define ARM_CLAW_SERVO_MIN (10)
#define ARM_CLAW_SERVO_MAX (45)
#define ARM_CLAW_SERVO_PIN (5)
#endif


void setup() {
  Serial.begin(9600);

#if defined TEST_BASE
  servo_base.attach(ARM_BASE_SERVO_PIN);
#endif

#if defined TEST_LEFT
  servo_left.attach(ARM_LEFT_SERVO_PIN);
#endif

#if defined TEST_RIGHT
  servo_right.attach(ARM_RIGHT_SERVO_PIN);
#endif

#if defined TEST_CLAW
  servo_claw.attach(ARM_CLAW_SERVO_PIN);
#endif
}




void loop()
{

  int base_position = 90;
  int left_position = 90;
  int right_position = 90;
  int last_base_position = 0;
  int last_left_position = 0;
  int last_right_position = 0;
  int claw;


  while (Serial.available() > 0)
  {

    base_position = Serial.parseInt();
    left_position = Serial.parseInt();
    right_position = Serial.parseInt();

    servo_base.write(base_position);
    servo_left.write(left_position);
    servo_right.write(right_position);

    Serial.print("Set rArm base servo value: ");
    Serial.print(base_position);
    //delay(2000);
    Serial.print('\n');
    Serial.print("Set rArm left servo value: ");
    Serial.print(left_position);
    Serial.print('\n');
    Serial.print("Set rArm right servo value: ");
    Serial.print(right_position);
    Serial.print('\n');

    //delay(2000);

    Serial.parseInt();
    Serial.parseInt();
    Serial.parseInt();




  } 
}
