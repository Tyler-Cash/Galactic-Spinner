int starCoordsX[] = new int[100];
int starCoordsY[] = new int[100];
int highscoreScore[] = new int[10];
int wormholeDiameter;
int score;
int scoreLocation;
int shipDiameter;
int gameState;

float wormholeX;
float wormholeY;
float x;
float y;
float direction;
float increment;
float speed;

boolean clockwise = true;
boolean enlargeWormhole = true;

String highscoreName[] = new String[10];
String name;

public boolean warp() {
  // Checks if the ship hits the wormhole
  if (dist(x, y, wormholeX, wormholeY) < (wormholeDiameter / 2)
    + (shipDiameter / 2)) {
    return true;
  }
  return false;
}

// /Handles collision with blackholes
// also draws them on thin the frame
public void blackHoleAt(float holeX, float holeY) {
  fill(0);
  stroke(255);

  int blackholeDiameter = 40;

  // Calcaulates the difference between the center point of the black
  // hole and the ship
  if (dist(x, y, holeX, holeY) < (blackholeDiameter / 2)
    + (shipDiameter / 2)) {

    // HIGHSCORE SYSTEM
    int i = 0;
    boolean menu = true;

    while (i < 10) {
      if (score > highscoreScore[i]) {
        menu = false;
        sortScores(score, i);
        i += 20;
      }
      i++;
    }// Boots back to menu if no new highscore is found
    if (menu) {
      gameState = 0;
    } else {
      gameState = 4;
    }
  } else {

    ellipse(holeX, holeY, 40, 40);
  }
}

public void setup() {

  frame.setTitle("Galactic Spinner");
  frame.setResizable(false);

  size(600, 600);
  frameRate(60);
  textAlign(CENTER);

  // Prepares variables
  starsGenerate();
  resetName();
  shipDiameter = 20;

  for (int i = 0; i < highscoreName.length; i++) {
    highscoreName[i] = null;
  }
}

public void draw() {

  // Switch statement controls the game mode
  switch (gameState) {

    // Menu is default
  default:
    menuScreen();
    break;

    // Game in progress
  case 1:
    // Draws various components in the window
    drawStars(0, 0);
    drawWormhole();
    blackHoleAt(100, 40);
    blackHoleAt(400, 500);
    drawScore(0);

    shipCoordCalc();
    drawShip();

    // Handles collission with wormhole
    if (warp()) {
      drawScore(1);
      wormholeGenerate();
      starsGenerate();
    }
    break;

    // Displays a how tp play screen
  case 2:
    helpScreen();
    break;

  case 3:
    background(0);
    highscoreScreen();
    break;
  case 4:
    background(0);
    newHighscore();
  }
}

public void keyPressed() {

  // Locks all button unless game is being played
  if (gameState == 1) {
    switch (key) {

      // Alternates direction of ship
    default:
      if (clockwise) {
        clockwise = false;
      } else {
        clockwise = true;
      }
      break;

      // Parallax of stars
    case 'w':
      drawStars(0, 1);
      forceDrawWindow();
      break;

    case 'a':
      drawStars(1, 0);
      forceDrawWindow();
      break;

    case 's':
      drawStars(0, -1);
      forceDrawWindow();
      break;

    case 'd':
      drawStars(-1, 0);
      forceDrawWindow();
      break;
    }
     //if entering new name
  } else if (gameState == 4) {
    //key == letter
    if (keyCode <= 90 && keyCode >= 65) {
      //Adds letter to the end of the array
      String temp[] = new String[name.length()];
      boolean addChar = true;
      for (int i = 0; i < name.length (); i++) {
        if (name.charAt(i) == ' ' && addChar) {
          temp[i] = str(key);
          temp[i].toUpperCase();
          addChar = false;
        } else {
          temp[i] = str(name.charAt(i));
        }
      }
      name = join(temp, "");
    }
  }
}

public void mousePressed() {
  // Handles hitreg of mouse clicks
  if (gameState != 1 && gameState != 4) {
    if (mouseButton == 37) {
      // Play
      if ((mouseX > 200 && mouseX < 400)
        && (mouseY > 220 && mouseY < 290)) {
        resetGame();
        // Highscores
      } else if ((mouseX > 200 && mouseX < 400)
        && (mouseY > 320 && mouseY < 390)) {
        println("help");
        gameState = 2;
        // Help screen
      } else if ((mouseX > 200 && mouseX < 400)
        && (mouseY > 420 && mouseY < 490)) {
        println("highscores");
        gameState = 3;
      } else if ((mouseX > 485 && mouseX < 505)
        && (mouseY > 65 && mouseY < 85)) {
        gameState = 0;
      }
      println("x = " + str(mouseX) + " " + "y = " + str(mouseY));
    }
  } else if (gameState == 4) {
    if ((mouseX > 515 && mouseX < 535)
      && (mouseY > 190 && mouseY < 210)) {
      gameState = 3;
    }
    if ((mouseX > 420 && mouseX < 495)
      && (mouseY > 300 && mouseY < 320)) {
      resetName();
    } else if ((mouseX > 420 && mouseX < 495)
      && (mouseY > 330 && mouseY < 350))
      if (name != null) {
        highscoreName[scoreLocation] = name;
        gameState = 3;
        resetName();
      }
  }
}

public void resetName() {
  name = "     ";
}

public void resetGame() {
  // Reset all variables so that the game will be identical
  // everytime it's played. (this doesn't include wormhole
  // coordinates)
  wormholeGenerate();
  wormholeDiameter = 1;
  score = 0;
  shipDiameter = 20;
  gameState = 1;

  wormholeX = random(80, 520);
  wormholeY = random(80, 520);
  x = 300;
  y = 300;
  direction = 0;
  increment = 1;
  speed = 5;
  clockwise = true;
  enlargeWormhole = true;
}

public void forceDrawWindow() {
  // Called on movement of stars to reduce latency if
  // stars are moved mid draw call.
  drawWormhole();
  blackHoleAt(100, 40);
  blackHoleAt(400, 500);
  drawScore(0);
  drawShip();
}

public void starsGenerate() {
  // populates arrays that represent star coordinates
  for (int i = 0; i < 100; i++) {
    starCoordsX[i] = PApplet.parseInt(random(600));
    starCoordsY[i] = PApplet.parseInt(random(600));
  }
}

public void wormholeGenerate() {
  // generates wormhole coordinates and resets size variable

    // Only runs if wormhole is meant to be reset. This places the wormhole
  // in a
  // random location and resets all parameters pertaining to it.
  wormholeX = PApplet.parseInt(random(80, 520));
  wormholeY = PApplet.parseInt(random(80, 520));
  wormholeDiameter = 0;
  enlargeWormhole = true;
}

public void shipCoordCalc() {
  // Calculates the x and y of ship based off of sin and cos waves
  // Controls direction of the ship
  if (clockwise) {
    direction += increment * 0.03;
  } else {
    direction += increment * -0.03;
  }

  x = x + speed * cos(direction);
  y = y + speed * sin(direction);

  // Prevents ship from drawing 'off' the window.
  // If the ship leaves the window it'll be placed on the opposite
  // side
  if (x > 600) {
    x = 0;
  } else if (x < 0) {
    x = 600;
  }
  if (y > 600) {
    y = 0;
  } else if (y < 0) {
    y = 600;
  }
}

public void drawShip() {
  // Draws space ship
  fill(255);
  ellipse(x, y, shipDiameter, shipDiameter);
}

public void drawWormhole() {
  // Draws wormhole
  ellipse(wormholeX, wormholeY, wormholeDiameter, wormholeDiameter);

  // Increases/decreases size of wormhole dependant on the value
  // of enlargeWormhole
  if (enlargeWormhole) {
    wormholeDiameter += 1;
    if (wormholeDiameter > 80) {
      enlargeWormhole = false;
    }
  } else {
    wormholeDiameter -= 1;
    if (wormholeDiameter < 0) {
      enlargeWormhole = true;
    }
  }
}

public void drawStars(int offsetX, int offsetY) {
  // draws stars in the window
  background(0);
  fill(255);
  stroke(0);

  // Draws and offsetts all stars. If a star is drawn outside of the
  // window a new star is then randomly generated.
  for (int i = 0; i < 100; i++) {
    starCoordsX[i] += offsetX;
    starCoordsY[i] += offsetY;

    // If the stars fall off the screen they are regenerated
    // This prevents a pattern from forming
    if (starCoordsX[i] > 600) {
      starCoordsX[i] = 1;
      starCoordsY[i] = PApplet.parseInt(random(0, 600));
    } else if (starCoordsX[i] < 0) {
      starCoordsX[i] = 599;
      starCoordsY[i] = PApplet.parseInt(random(0, 600));
    }

    if (starCoordsY[i] > 600) {
      starCoordsY[i] = 1;
      starCoordsX[i] = PApplet.parseInt(random(0, 600));
    } else if (starCoordsY[i] < 0) {
      starCoordsY[i] = 599;
      starCoordsX[i] = PApplet.parseInt(random(0, 600));
    }

    ellipse(starCoordsX[i], starCoordsY[i], 2, 2);
  }
}

public void drawScore(int modifier) {
  // Draws user's score in the bottom left hand corner
  score += modifier;
  textSize(20);
  fill(255);
  text("Score = " + str(score), 100, 560);
}

public void menuScreen() {
  // Main menu screen
  String message = "";

  background(0);

  // Rolling stars for cinematic effect
  drawStars(0, 1);

  // Draws title
  textSize(60);
  text("Galactic Spinner", 300, 130);
  textSize(30);

  // Draws the 3 buttons with their labels
  for (int y = 220; y < 430; y += 100) {
    drawFrame(200, y, 200, 70);

    switch (y) {
    case 220:
      message = "Play";
      break;
    case 320:
      message = "Help";
      break;
    case 420:
      message = "High Scores";
      break;
    }
    fill(255);
    text(message, 300, y + 45);
  }
}

public void drawFrame(int X, int Y, int frameWidth, int frameHeight) {
  // Function used to draw frames
  fill(255);
  rect(X, Y, frameWidth, frameHeight);
  fill(0);
  rect(X + 2, Y + 2, frameWidth - 4, frameHeight - 4);
}

public void helpScreen() {
  // Screen used to teach player how to play (If they're unclear
  // of the mechanics)
  // Code is pretty much in shambles here

  // Draws background
  background(0);
  strokeWeight(1);
  stroke(255);
  drawStars(0, 1);

  // Draws main frame
  drawFrame(100, 70, 400, 430);
  // Draws preview and tooltip
  for (int i = 140; i < 400; i += 120) {
    String message1;
    String message2;
    String message3 = " ";
    switch (i) {

      // Menu is default
    default:
      message1 = "Hit the wormhole";
      message2 = "to gain 1 point";
      break;

      // Game in progress
    case 260:
      message1 = "Avoid hitting the ";
      message2 = "black hole or it'll";
      message3 = "destroy your ship!";
      break;
    case 380:
      message2 = "This is your ship";
      message1 = " ";
      break;
    }
    drawFrame(130, i, 100, 100);
    drawFrame(250, i, 220, 100);
    fill(255);
    textSize(20);
    textAlign(LEFT);
    text(message1, 270, i + 40);
    text(message2, 270, i + 60);
    text(message3, 270, i + 80);
  }
  // Header of window
  textSize(30);
  textAlign(CENTER);
  text("Help", 315, 115);

  // Draws wormhole
  fill(255);
  wormholeX = 180;
  wormholeY = 190;
  drawWormhole();

  // Draws blackhole
  blackHoleAt(180, 310);

  // Draws ship
  x = 180;
  y = 430;
  drawShip();

  // Draws cross to signify where the user
  // should click to close the window
  drawCross(485, 65);

  // Resets text size
  textSize(30);
}

public void drawCross(int x, int y) {
  fill(0);
  // Draws cross frame
  strokeWeight(1);
  stroke(0);
  drawFrame(x, y, 20, 20);
  fill(255);
  stroke(255);
  line(x + 4, y + 4, x + 16, y + 16);
  line(x + 4, y + 16, x + 16, y + 4);
}

public void newHighscore() {
  highscoreScreen();
  // Main frame
  drawFrame(75, 200, 450, 200);
  // Input box frame
  drawFrame(150, 300, 250, 50);
  // Reset button
  drawFrame(420, 300, 70, 20);
  // Enter button
  drawFrame(420, 330, 70, 20);
  drawCross(514, 192);

  fill(255);
  textSize(15);
  text("Reset", 452, 315);
  text("Enter", 454, 345);

  textSize(20);
  text("Congratualtions! New high score", 300, 230);
  text("What's your name? (Up to 4 letters)", 300, 260);

  strokeWeight(2);
  int offsetX = 47;
  for (int i = 0; i < 5; i++) {
    if (name.charAt(i) == ' ') {
      line(offsetX * i + 160, 340, offsetX * i + 195, 340);
    } else {
      fill(255);
      textSize(30);
      text(str(name.charAt(i)), offsetX * i + 175, 335);
    }
  }
  strokeWeight(1);
}

public void highscoreScreen() {
  // Rolling stars for cinematic effect
  drawStars(0, 1);
  // Main frame
  drawFrame(100, 70, 400, 430);
  drawCross(485, 65);

  // Draws headers
  fill(255);
  textSize(20);
  text("NAME", 200, 100);
  text("SCORE", 400, 100);

  line(102, 115, 498, 115);
  line(300, 72, 300, 113);
  // Draws array of scores + names

  for (int i = 0; i < highscoreScore.length - 1; i++) {
    if (highscoreName[i] != null) {
      String temp = highscoreName[i];
      line(102, i * 31 + 146, 498, i * 31 + 146);
      line(300, i * 31 + 115, 300, i * 31 + 146);
      text(temp, 200, (i * 31 + 138));
      text(str(highscoreScore[i]), 400, (i * 31 + 138));
    }
  }
}

public void sortScores(int newScore, int i) {
  // Saves score location so it can be used later
  scoreLocation = i;
  int temp1;
  int temp3 = newScore;
  String temp2;
  // Mysery man stays if user doesn't input name.
  String temp4 = "MYSTERY MAN";
  for (i = i; i < 10; i++) {
    temp1 = highscoreScore[i];
    temp2 = highscoreName[i];
    highscoreScore[i] = temp3;
    highscoreName[i] = temp4;
    temp3 = temp1;
    temp4 = temp2;
  }
}

