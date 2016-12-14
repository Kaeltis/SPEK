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

  /*

   List<Feature> airports = GeoJSONReader.loadData(this, "Flughafen 24h-Pegel L-den.json");
   List<Marker> airportMarkers = new ArrayList<Marker>();
   for (Feature feature : airports) {
   ShapeFeature lineFeature = (ShapeFeature) feature;
   
   SimpleLinesMarker m = new SimpleLinesMarker(lineFeature.getLocations());
   int dba = lineFeature.getIntegerProperty("DBA");
   float mappedDba = map(dba, 40, 100, 0, 255);
   int colour = color(44, 91, mappedDba);
   m.setColor(colour);
   m.setStrokeWeight(5);
   airportMarkers.add(m);
   }
   map.addMarkers(airportMarkers);
   
   List<Feature> rails = GeoJSONReader.loadData(this, "Schiene Deutsche Bahn 24h-Pegel L-den.json");
   List<Marker> railMarkers = MapUtils.createSimpleMarkers(rails);
   map.addMarkers(railMarkers);
   */

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