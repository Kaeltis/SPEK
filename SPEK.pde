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

UnfoldingMap map;

void setup() {
  size(800, 600, P2D);
  smooth();

  map = new UnfoldingMap(this);
  map.zoomAndPanTo(11, new Location(50.94, 6.95));
  MapUtils.createDefaultEventDispatcher(this, map);

  startMarkerGenerators();
}

void draw() {
  synchronized(map) {
    map.draw();
  }
}

void keyPressed() {
  switch(key) {
  case ' ':
    synchronized(map) {
      map.getDefaultMarkerManager().toggleDrawing();
    }
    break;
  }
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
    case 2:
      generateStreetNoiseMarkers();
      break;
    case 3:
      generateDBNoiseMarkers();
      break;
    case 4:
      generateKVBandHGKNoiseMarkers();
      break;
    case 5:
      generateNoiseMarkers("Industrie-Hafen-lden.geojson");
      break;
    case 6:
      generateNoiseMarkers("Flughafen-lden.geojson");
      break;
    }
  }

  void generateStreetNoiseMarkers () {
    for (int i = 0; i <= 60; i++) {
      generateNoiseMarkers("Strasse-lden_"+ String.format("%04d", i) +".geojson");
    }
  }

  void generateDBNoiseMarkers () {
    for (int i = 0; i <= 12; i++) {
      generateNoiseMarkers("Bahn-DB-lden_"+ String.format("%04d", i) +".geojson");
    }
  }

  void generateKVBandHGKNoiseMarkers () {
    for (int i = 0; i <= 1; i++) {
      generateNoiseMarkers("Bahn-KVB-HGK-lden_"+ String.format("%04d", i) +".geojson");
    }
  }

  void generateNoiseMarkers(String file) {
    println("[DEBUG] Generating Markers for " + file);

    List<Feature> noise = GeoJSONReader.loadData(SPEK.this, file);

    List<Marker> noiseMarkers = MapUtils.createSimpleMarkers(noise);

    synchronized (map) {
      map.addMarkers(noiseMarkers);
    }

    for (Marker marker : noiseMarkers) {
      int dbaLevel = marker.getIntegerProperty("DBA");
      ColourTable myCTable = ColourTable.getPresetColourTable(ColourTable.RD_YL_BU, 50, 75);
      // 125-dbaLevel to invert color scheme, also add 127 alpha
      marker.setColor((myCTable.findColour(125-dbaLevel)&0x00FFFFFF)+(127<<24));
      marker.setStrokeWeight(0);
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
    println("[DEBUG] Generating Markers for " + file);

    List<Feature> green = GeoJSONReader.loadData(SPEK.this, file);
    List<Marker> greenMarkers = MapUtils.createSimpleMarkers(green);

    synchronized (map) {
      map.addMarkers(greenMarkers);
    }

    for (Marker marker : greenMarkers) {
      marker.setColor(color(0, 200, 0, 127));
      marker.setStrokeWeight(0);
    }
  }
}