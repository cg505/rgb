#define REDPIN 5
#define GREENPIN 6
#define BLUEPIN 3

#define FADESPEED 5

void setup() {
	pinMode(REDPIN, OUTPUT);
	pinMode(GREENPIN, OUTPUT);
    pinMode(BLUEPIN, OUTPUT);

	Serial.begin(9600);
}

int waitRead() {
	int byt;
	while(!Serial.available() || (byt = Serial.read()) == -1);
	return byt;
}

void loop() {
	int carryover;
	while(true) {
		int zero = carryover;
		int one = 0;
		while(zero != 0) {
			zero = waitRead();
		}

		while(one == 0) {
			one = waitRead();
		}

		if(zero == 0 && one == 1) {
			break;
		}

		carryover = one;
	}

	int r, g, b, one;

	r = waitRead();
	g = waitRead();
	b = waitRead();
	one = waitRead();
	if(one == 1 &&
	   r == waitRead() &&
	   g == waitRead() &&
	   b == waitRead()) {
		Serial.write((r + g + b) % 256);
		analogWrite(REDPIN, r);
		analogWrite(GREENPIN, g);
		analogWrite(BLUEPIN, b);
	}
}
