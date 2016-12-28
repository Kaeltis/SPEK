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

UnfoldingMap map;
PFont f;

int finishedGeneratorCount;

void setup() {
  size(800, 600, P2D);
  smooth();

  f = createFont("Arial Bold", 16, true);

  map = new UnfoldingMap(this);
  map.zoomAndPanTo(11, new Location(50.94, 6.95));
  MapUtils.createDefaultEventDispatcher(this, map);

  finishedGeneratorCount = 0;
  startMarkerGenerators();
}

void draw() {
  background(0);

  if (finishedGeneratorCount == COMPLETE_GENERATOR_COUNT) {
    map.draw();
  } else {
    drawMessage("Please wait while the map is being generated - " + String.format("%.0f", map(finishedGeneratorCount, 0, COMPLETE_GENERATOR_COUNT, 0, 100)) + "%");
  }
}

void keyPressed() {
  switch(key) {
  case ' ':
    map.getDefaultMarkerManager().toggleDrawing();
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
      generateAllGreenMarkers();
      break;
   
    
    }
  }
  
  }

  void generateAllGreenMarkers() {
    generateGreenMarkers("Gruen-Biotopflaechen.geojson");
    generateGreenMarkers("Gruen-ForsteigeneFlaechen.geojson");
    generateGreenMarkers("Gruen-Gruenanlagen.geojson");
    generateGreenMarkers("Gruen-Kleingaerten.geojson");
    generateGreenMarkers("Gruen-Sondergruenflaechen.geojson");
    generateGreenMarkers("Gruen-Spielplaetze.geojson");
  }

  void generateGreenMarkers(String file) {
    if (DEBUG)
      println("[DEBUG] Generating Markers for " + file);

    List<Feature> green = GeoJSONReader.loadData(sketchProj.this, file);
    List<Marker> greenMarkers = MapUtils.createSimpleMarkers(green);

    map.addMarkers(greenMarkers);

    for (Marker marker : greenMarkers) {
      marker.setColor(color(100, 200, 0, 127));
      marker.setStrokeWeight(0);
    }

    finishedGeneratorCount++;
  }
//Focus auf ausgewählte Grünfläche
void mouseClicked(){  
  
  Marker gruenFlaechenName = map.getFirstHitMarker(mouseX, mouseY);
  
  if (gruenFlaechenName != null) {
        // Select current marker 
        //spielPlatz.setSelected(true);
        gruenFlaechenName.getStringProperty("Name");
        map.setTweening(true);
        map.zoomAndPanToFit(gruenFlaechenName);
        gruenFlaechenName.setColor(color(0, 200, 0, 127));
        
    } else {
        // Deselect all other markers
        for (Marker marker : map.getMarkers()) {
            marker.setSelected(false);
        }
    } 
}