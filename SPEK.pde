import controlP5.*;

import g4p_controls.*;

import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.mapdisplay.shaders.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.texture.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.ui.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.utils.*;
import java.util.List;
import org.gicentre.utils.colour.*;

static final boolean DEBUG = true;
static final int COMPLETE_GENERATOR_COUNT = 6;

Location koelnLocation = new Location(50.94, 6.95);
int koelnZoomLevel = 11;

UnfoldingMap mapDetail;
UnfoldingMap mapOverview;
//UnfoldingMap map;
PFont f;
boolean showMapOverview = false;
boolean secondShow = false;


ControlP5 controlP5;
int messageBoxResult = -1;
ControlGroup messageBox;

EventDispatcher eventDispatcher;

int finishedGeneratorCount;

void setup() {
  size(800, 600, P2D);
  createGUI();
  smooth();
  Startseite.setVisible(false);

  f = createFont("Arial Bold", 16, true);
  controlP5 = new ControlP5(this);

  // GButton bahnButton = new GButton(this, 30, 40, 110, 20, "Bahn");
  // Change the background for b1
  //bahnButton.setLocalColor(4, color(255, 0)); // mouse off colour
  // b1.setLocalColor(6, color(255, 0)); 

  mapDetail = new UnfoldingMap(this, "detail", 10, 10, 800, 600);
  mapDetail.zoomAndPanTo(koelnZoomLevel, koelnLocation);
  mapDetail.setTweening(true);
  mapOverview = new UnfoldingMap(this, "overview", 10, 455, 185, 185);
  mapOverview.zoomAndPanTo(10, koelnLocation);
  /*map = new UnfoldingMap(this);
   map.zoomAndPanTo(11, new Location(50.94, 6.95));
   MapUtils.createDefaultEventDispatcher(this, map);*/

  eventDispatcher = MapUtils.createDefaultEventDispatcher(this, mapDetail);
  eventDispatcher.register(mapOverview, "pan", mapDetail.getId(), mapOverview.getId());
  eventDispatcher.register(mapOverview, "zoom", mapDetail.getId(), mapOverview.getId());

  finishedGeneratorCount = 0;
  startMarkerGenerators();
}

void draw() {
  background(0);
  mapDetail.setZoomRange(5, 15);

  if (finishedGeneratorCount == COMPLETE_GENERATOR_COUNT) {
    mapDetail.draw();
    if (showMapOverview == true) {
      mapOverview.draw();
    }
  } else {
    drawMessage("Please wait while the map is being generated - " + String.format("%.0f", map(finishedGeneratorCount, 0, COMPLETE_GENERATOR_COUNT, 0, 100)) + "%");
  }
}

void keyPressed() {
  switch(key) {
  case ' ':
    mapDetail.getDefaultMarkerManager().toggleDrawing();
    mapOverview.getDefaultMarkerManager().toggleDrawing();
    break;
  }
}

void drawMessage(String message) {
  textFont(f, 16);
  fill(255);
  text(message, 10, 25);
}

void startMarkerGenerators() {
  for (int i = 1; i <= 6; i++) {
    new MarkerGenerator(i).start();
  }
}

class MarkerGenerator extends Thread {
  int type;

  public MarkerGenerator(int type) {
    this.type = type;
  }

  public void run()
  {
    switch(type) {
    case 1:
      generateGreenMarkers("Gruen.json");
      break;
    case 2:
      generateNoiseMarkers("Strasse.json");
      break;
    case 3:
      generateNoiseMarkers("Bahn-DB.json");
      break;
    case 4:
      generateNoiseMarkers("Bahn-KVB-HGK.json");
      break;
    case 5:
      generateNoiseMarkers("Industrie-Hafen.json");
      break;
    case 6:
      generateNoiseMarkers("Flughafen.json");
      break;
    }
  }

  void generateGreenMarkers(String file) {
    if (DEBUG)
      println("[DEBUG] Generating Markers for " + file);

    List<Feature> green = GeoJSONReader.loadData(SPEK.this, file);
    List<Marker> greenMarkers = MapUtils.createSimpleMarkers(green);

    mapDetail.addMarkers(greenMarkers);
    mapOverview.addMarkers(greenMarkers);

    for (Marker marker : greenMarkers) {
      marker.setColor(color(100, 200, 0, 127));
      marker.setStrokeWeight(0);

      // int polygonFlaeche = marker.getIntegerProperty("Shape_Area");
      /*int polygonLaenge = marker.getIntegerProperty("StrS");
       float distance = dist(mouseX, mouseX, polygonLaenge, polygonLaenge);
       if(distance < polygonLaenge){
       fill(255);
       text("Boop!",mouseX-20,mouseY-10);
       }*/
    }

    finishedGeneratorCount++;
  }

  void generateNoiseMarkers(String file) {
    if (DEBUG)
      println("[DEBUG] Generating Markers for " + file);

    List<Feature> noise = GeoJSONReader.loadData(SPEK.this, file);

    List<Marker> noiseMarkers = MapUtils.createSimpleMarkers(noise);

    mapDetail.addMarkers(noiseMarkers);
    mapOverview.addMarkers(noiseMarkers);

    for (Marker marker : noiseMarkers) {
      int dbaLevel = marker.getIntegerProperty("DBA");
      ColourTable myCTable = ColourTable.getPresetColourTable(ColourTable.RD_YL_BU, 50, 75);
      // 125-dbaLevel to invert color scheme, also add 127 alpha
      marker.setColor((myCTable.findColour(125-dbaLevel)&0x00FFFFFF)+(127<<24));
      marker.setStrokeWeight(0);
    }

    if (DEBUG)
      println("[DEBUG] Finished Generating Markers for " + file);
    finishedGeneratorCount++;
  }
}

//Focus auf ausgewählte Grünfläche
void mouseClicked() {  

  Marker gruenFlaechenName = mapDetail.getFirstHitMarker(mouseX, mouseY);
  if (gruenFlaechenName != null) {
    // Select current marker 
    //spielPlatz.setSelected(true);
    strasseButton.setVisible(false);
    bahnButton.setVisible(false);
    industrieButton.setVisible(false);
    schienenButton.setVisible(false);
    flughafenButton.setVisible(false);
    Startseite.setVisible(true);
    showMapOverview = true;
    String name = gruenFlaechenName.getStringProperty("Name");
    println(name);
    mapDetail.setTweening(true);
    mapDetail.zoomAndPanToFit(gruenFlaechenName);
    //mapOverview.setTweening(true);
    //mapOverview.zoomAndPanToFit(gruenFlaechenName);
    gruenFlaechenName.setColor(color(0, 200, 0, 127));
    //createMessageBox();
  } else {
    // Deselect all other markers
    for (Marker marker : mapDetail.getMarkers()) {
      marker.setSelected(false);
      showMapOverview = false;
    }
  }
}

/*void createMessageBox() { 
 // create a group to store the messageBox elements
 messageBox = controlP5.addGroup("messageBox",width/2+100,180,200);
 messageBox.setBackgroundHeight(300);
 messageBox.setBackgroundColor(color(255,255));
 messageBox.hideBar();
 
 // add a TextLabel to the messageBox.
 Textlabel GruenflaecheDetails = controlP5.addTextlabel("messageBoxLabel","Details bezüglich den Gruenflaechen",20,20);
 GruenflaecheDetails.setColor(0);
 GruenflaecheDetails.moveTo(messageBox);
 
 controlP5.Button b1 = controlP5.addButton("buttonOK")
 .setPosition(100,250)
 .setSize(80,24)
 .setId(1);
 b1.moveTo(messageBox);
 b1.setBroadcast(false);
 b1.setValue(1);
 b1.setBroadcast(true);
 b1.setCaptionLabel("OK"); 
 }
 
 void buttonOK(int theValue) {
 //println("a button event from button OK.");
 messageBoxResult = theValue;
 messageBox.hide();
 }*/