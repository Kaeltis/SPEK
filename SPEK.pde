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
DebugDisplay debugDisplay;

void setup() {
  size(800, 600, P2D);
  smooth();

  map = new UnfoldingMap(this);
  map.zoomAndPanTo(10, new Location(50.94, 6.95));
  EventDispatcher eventDispatcher = MapUtils.createDefaultEventDispatcher(this, map);
  debugDisplay = new DebugDisplay(this, map, eventDispatcher, 10, 10);

  generateNoiseMarkers("Industrie-Hafen-lden.geojson");

  generateGreenMarkers("Gruen-Biotopflaechen.geojson");
  generateGreenMarkers("Gruen-ForsteigeneFlaechen.geojson");
  generateGreenMarkers("Gruen-Gruenanlagen.geojson");
  generateGreenMarkers("Gruen-Kleingaerten.geojson");
  generateGreenMarkers("Gruen-Sondergruenflaechen.geojson");
  generateGreenMarkers("Gruen-Spielplaetze.geojson");
}

void draw() {
  map.draw();
}

void mouseMoved() {
  Marker marker = map.getFirstHitMarker(mouseX, mouseY);
  if (marker != null) {
    println(marker.getIntegerProperty("DBA"));
  }
}

void keyPressed() {
  if (key == ' ') {
    map.getDefaultMarkerManager().toggleDrawing();
  }
}

void generateNoiseMarkers(String file) {
  List<Feature> noise = GeoJSONReader.loadData(this, file);

  List<Marker> noiseMarkers = MapUtils.createSimpleMarkers(noise);
  map.addMarkers(noiseMarkers);

  for (Marker marker : noiseMarkers) {
    int dbaLevel = marker.getIntegerProperty("DBA");
    ColourTable myCTable = ColourTable.getPresetColourTable(ColourTable.RD_YL_BU, 50, 75);
    // 125-dbaLevel to invert color scheme
    marker.setColor(myCTable.findColour(125-dbaLevel));
    marker.setStrokeColor(myCTable.findColour(125-dbaLevel));
  }
}

void generateGreenMarkers(String file) {
  List<Feature> green = GeoJSONReader.loadData(this, file);
  List<Marker> greenMarkers = MapUtils.createSimpleMarkers(green);
  map.addMarkers(greenMarkers);

  for (Marker marker : greenMarkers) {
    marker.setColor(color(0, 200, 0, 127));
    marker.setStrokeColor(color(1, 0));
  }
}