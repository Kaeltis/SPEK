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
  map.zoomAndPanTo(10, new Location(50.94, 6.95));
  MapUtils.createDefaultEventDispatcher(this, map);

  List<Feature> noise = GeoJSONReader.loadData(this, "Bahn-DB-lden_0000.geojson");
  
  List<Marker> noiseMarkers = MapUtils.createSimpleMarkers(noise);
  map.addMarkers(noiseMarkers);
  
  for (Marker marker : noiseMarkers) {
    int dbaLevel = marker.getIntegerProperty("DBA");
    //float redValue = map(dbaLevel, 50, 75, 50, 255);
    ColourTable myCTable = ColourTable.getPresetColourTable(ColourTable.RD_YL_BU,10,100);
   // marker.setColor(color(redValue, 0, 0, 127));
    marker.setColor(myCTable.findColour(dbaLevel));
    marker.setStrokeColor(myCTable.findColour(dbaLevel)); 
   // fill(myCTable.findColour(dbaLevel));
   // stroke(myCTable.findColour(dbaLevel));

    
   /*   float inc = 0;
  for (float i=0; i<1; i+=inc)
  {
    fill(myCTable.findColour(i));
    stroke(myCTable.findColour(i));
    //rect(width*i,10,width*inc,50);
  }*/
  }
  
}

void draw() {
  map.draw();
  
 
}

/*void mouseMoved() {
  Marker marker = map.getFirstHitMarker(mouseX, mouseY);
  if (marker != null) {
    println(marker.getStringProperty("name"));
  }
}*/


void keyPressed() {
  if (key == ' ') {
    map.getDefaultMarkerManager().toggleDrawing();
  }
}