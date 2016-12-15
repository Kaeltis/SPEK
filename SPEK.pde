/**
 * Displays countries of the world as simple polygons.
 * 
 * Reads from a GeoJSON file, and uses default marker creation. Features are polygons.
 * 
 * Press SPACE to toggle visibility of the polygons.
 */

import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.geo.*;
import java.util.List;

Location cologneLocation = new Location(50.938056f, 6.956944f);

UnfoldingMap map;

void setup() {
  size(800, 600, P2D);
  smooth();

  map = new UnfoldingMap(this);
  map.zoomToLevel(10);
  map.panTo(cologneLocation);
  map.setZoomRange(9, 17);
  map.setPanningRestriction(cologneLocation, 15);
  MapUtils.createDefaultEventDispatcher(this, map);

  List<Feature> railsKH = GeoJSONReader.loadData(this, "Bahn-KVB-HGK-lden_0000.geojson");
  List<Marker> railKHMarkers = MapUtils.createSimpleMarkers(railsKH);
  map.addMarkers(railKHMarkers);
  
  /*
  List<Marker> railKHMarkers = new ArrayList<Marker>();
  for (Feature feature : railsKH) {
    ShapeFeature lineFeature = (ShapeFeature) feature;

    SimpleLinesMarker m = new SimpleLinesMarker(lineFeature.getLocations());
    int dba = lineFeature.getIntegerProperty("DBA");
    float mappedDba = map(dba, 40, 100, 0, 255);
    int colour = color(44, 91, mappedDba);
    m.setColor(colour);
    m.setStrokeWeight(5);
    railKHMarkers.add(m);
  }
  map.addMarkers(railKHMarkers);
  */

  List<Feature> airports = GeoJSONReader.loadData(this, "Flughafen-lden.geojson");
  List<Marker> airportMarkers = MapUtils.createSimpleMarkers(airports);
  map.addMarkers(airportMarkers);

  List<Feature> industrials = GeoJSONReader.loadData(this, "Industrie-Hafen-lden.geojson");
  List<Marker> industrialMarkers = MapUtils.createSimpleMarkers(industrials);
  map.addMarkers(industrialMarkers);
  
}

void draw() {
  map.draw();
}

void keyPressed() {
  if (key == ' ') {
    map.getDefaultMarkerManager().toggleDrawing();
  }
}