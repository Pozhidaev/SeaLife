-------
SeaLife
=======

SeaLife is a project for experiments with iOS platform, drawing and multithreading.
It simulates life with two types of creatures with simple turn rules. 

![Screenshot 1](/Screenshot_1.png)
![Screenshot 2](/Screenshot_2.png)

Every creature can do one thing per turn:
Fish can move or reproduce itself one time in X turns (X - kFishReproductionPeriod)
Orca can move or reproduce itself one time in X turns (X - kOrcaReproductionPeriod), or eat fish. If Orca doesn't eat more then Y turns it dies (Y - kOrcaAllowedHungerPoins) 
Concrete values are in Constants.h file

Creatures turns are performed by timers

## Project capabilities:
* you can customize creatures count on start
* you can customize world size on start, but with constant aspect ratio
* you can customize creatures timers speed while world is running
* you can customize creatures animations speed while world is running
* Support iPhone & iPad
* Support Dark/Light user interface
* Support portrait & landscape orientations