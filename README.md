ShallowWateriOS
===============

Real-time water simulation demos on iOS


This project contains several water simulation demos.

The mechanism driving the motion of the simulated water is derived from Navier-Storks Equation in Computational Fluid Dynamics.
The employed method is a combination of grid and particle based fluid simulation approaches. The water surface is represented by a 2D height field named Shallow Water Equation(SWE), which is a simplification of Navier-Storks Equation. A particle system is invited to represent the surface details such as waves and splashes. Simple two-way interactions between the fluid and solids are also implemented.

The demos are rendered with iSGL3D graphics library, which is available on http://isgl3d.com. Physical details are powered by bullet physics engine.
The programming language is Objective-C++, a combination of Objective-C and C++.
All the codes are compiled in Xcode 5 with iOS SDK 6.1. 
Caution: the project does not run well with iOS SDK 7.0+ due to compatibility problems of iSGL3D.
