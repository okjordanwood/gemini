# Gemini

[Project Gemini](https://github.com/SCCapstone/gemini/wiki) is a platformer game where the room's puzzle are not so much of moving around the 
area, but having the area being affected around you.

The way the game is structured is that for every level there is, there is a law of physics that 
the player must use to move around the area. One room could be the gravity is the equivalent to the moon, 
or one could be equivalent to Jupiter, thus making jumping impossible, meaning there must be a way to 
traverse the map without jumping. Other rooms may include, losing the ability to use friction, the platforms 
moves in the opposite direction the player moves, or even a combination of the previous rooms to add 2 different 
challenges instead of one. In order to complete this effect, we will be using Godot, with it's 
nodes functionality to build off each other nodes that causes an effect or an object to appear.

---

## External Requirements

In order to build this project you first have to install:

-   [Godot](https://godotengine.org/)
-   [Github Desktop](https://desktop.github.com/download/)

Windows 10/11 are able to run these

---

## Setup

There is no setup necessary for our app. Once you download the files into GoDOT, you are good to go.

---

## Running

Gemini can be run directly in the GoDOT engine. Once you download the files from the repo into GoDOT, you can click play at the top and play the game.

---

# Deployment

Webapps need a deployment section that explains how to get it deployed on the
Internet. These should be detailed enough so anyone can re-deploy if needed
. Note that you **do not put passwords in git**.

Mobile apps will also sometimes need some instructions on how to build a
"release" version, maybe how to sign it, and how to run that binary in an
emulator or in a physical phone.

---

# Testing

More Automated tests will be written in the coming weeks and will be found in the directories below.

The unit tests are in `/Tests/Unit`.

The behavioral tests are in `Tests/Behavior/`.

---

## Testing Technology

Gemini uses the GUT (Godot Unit Test) framework for automated testing within the Godot Engine.

---

## Running Tests

1. Go to Project → Project Settings → Plugins and enable the GUT plugin.
2. At the bottom of the screen, click the GUT tab
3. Scroll down to Test Directories, click Include Subdirs, then click the 3 dots and add the tests/ folder.
4. Finally, select Run All at the top of the GUT tab to execute all tests.

---

## 📄 License

This project is licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for details.

---

# Authors

Bryan Munoz-Romero
Jordan Wood                jcw43@email.sc.edu
Scott Prichard
Waleed Khan
Harmony
