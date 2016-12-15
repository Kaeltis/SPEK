import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.geo.*;
import java.util.List;

UnfoldingMap map;

void setup() {
  size(800, 600, P2D);
  smooth();

  map = new UnfoldingMap(this);
  map.zoomAndPanTo(10, new Location(50.94, 6.95));
  MapUtils.createDefaultEventDispatcher(this, map);

  List<Feature> noise = GeoJSONReader.loadData(this, "Industrie-Hafen-lden.geojson");
  
  List<Marker> noiseMarkers = MapUtils.createSimpleMarkers(noise);
  map.addMarkers(noiseMarkers);
  
  for (Marker marker : noiseMarkers) {
    int dbaLevel = marker.getIntegerProperty("DBA");
    float redValue = map(dbaLevel, 55, 75, 50, 255);
    marker.setColor(color(redValue, 0, 0, 127));
    marker.setStrokeColor(color(1, 0));
  }
  
}

void draw() {
  map.draw();
}

void mouseMoved() {
  Marker marker = map.getFirstHitMarker(mouseX, mouseY);
  if (marker != null) {
    println(marker.getStringProperty("name"));
  }
}


void keyPressed() {
  if (key == ' ') {
    map.getDefaultMarkerManager().toggleDrawing();
  }
}