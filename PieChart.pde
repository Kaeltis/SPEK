
import org.json.JSONObject;
import org.json.JSONArray;
import controlP5.*;

public class PieChart extends Chart {

  int counterStreet = 0;
  int counterRailDB = 0;
  /*counterRailKVG also contains HGK*/
  int counterRailKVG = 0;
  int counterIndustry = 0;
  int counterGreen = 0;
  ArrayList<Float> percentOfNoise = new ArrayList();
  float[] angles = new float[4];
  JSONArray coordinatesGreen = new JSONArray();
  ArrayList<JSONArray> streetCoordinates = new ArrayList();
  ArrayList<JSONArray> railDBCoordinates = new ArrayList();
  ArrayList<JSONArray> railKVGCoordinates = new ArrayList();
  ArrayList<JSONArray> industryCoordinates = new ArrayList();
  int myDisplayMode;
  ArrayList<JSONArray> allCoordinatesGreen = new ArrayList();

  public PieChart(ControlP5 theControlP5, ControllerGroup parent, java.lang.String theName, String nameOfGreen, float x, float y, int width, int height) {
    super(theControlP5, parent, theName, x, y, width, height);

    createPieChart(nameOfGreen);
  }

  void setPieChart(String gruenFlaechenName) {

    setCounterGreen(gruenFlaechenName);

    setCounterNoise("Street");
    setCounterNoise("DB");
    setCounterNoise("KVG");
    setCounterNoise("Industry");

    setPercent();
    calculateAngle();
  }

  void setCounterGreen(String gruenFlaechenName) {

    JSONObject greenData = new JSONObject("Gruen.json");

    counterGreen = getCounterNumber(greenData, gruenFlaechenName);
  }

  int getCounterNumber(JSONObject data, String name) {

    String geometryType = data.getString("type");
    if (geometryType == "MultiPolygon") {
      JSONArray geometry = parseGeometry(data);
      for (int l = 0; l < geometry.length(); l++) {
        try {
          allCoordinatesGreen.add(geometry.getJSONArray(l));
        }
        catch(Exception e) {
        }
      }
    } else if (data.has(name)) {
      allCoordinatesGreen.add(data.getJSONArray(name));
    }

    return coordinatesGreen.length();
  }

  void setCounterNoise(String dataName) {

    String fileName;
    JSONObject streetData;
    JSONObject dbData;
    JSONObject industryData;
    JSONObject kvgData;

    switch(dataName) {
    case "Strasse": 
      fileName = "Strasse.json";      
      streetData = new JSONObject(fileName);
      streetCoordinates = setCounterValue(streetData, "Street");
    case "DB": 
      fileName = "Bahn-DB.json";      
      dbData = new JSONObject(fileName);
      railDBCoordinates = setCounterValue(dbData, "DB");
    case "Industry":
      fileName = "Industrie-Hafen.json";      
      industryData = new JSONObject(fileName);
      industryCoordinates = setCounterValue(industryData, "Industry");
    case "KVG":
      fileName = "Bahn-KVB-HGK.json";      
      kvgData = new JSONObject(fileName);
      railKVGCoordinates = setCounterValue(kvgData, "KVG");
    default:
      //do nothing
    }
  }

  ArrayList setCounterValue(JSONObject obj, String name) {
    int counter = 0;
    ArrayList all = new ArrayList();

    JSONArray coordinates = new JSONArray();
    JSONArray geometry = new JSONArray();
    if (obj != null) {
      for (int i = 0; i < obj.length(); i++) {
        try {
          if (obj.has("geometry")) {
            geometry = parseGeometry(obj.getJSONObject("geometry"));
          }
          for (int l = 0; l < geometry.length(); l++) {
            coordinates = geometry.getJSONArray(l);
            all.add(coordinates);
          }

          //gets the number of coordinates
          for (int j = 0; j < coordinates.length(); j++) {
            JSONArray arrayValues = coordinates.getJSONArray(i);
            for (int k = 0; k < arrayValues.length(); k++) {
              counter++;
            }
          }
        }
        catch(Exception e) {
        }
      }
    }
    if (name == "Street") {
      counterStreet = counter;
    } else if (name == "DB") {
      counterRailDB= counter;
    } else if (name == "KVG") {
      counterRailKVG= counter;
    } else if (name == "Industry") {
      counterIndustry= counter;
    }
    return all;
  }

  JSONArray parseGeometry(JSONObject geoJsonGeometry) {
    try {
      String geometryType = geoJsonGeometry.getString("type");

      JSONArray geometryArray;
      if (isGeometry(geometryType)) {
        geometryArray = geoJsonGeometry.getJSONArray("coordinates");
        return geometryArray;
      } else {
        // No geometries or coordinates array
        return null;
      }
    } 
    catch (Exception e) {
      return null;
    }
  }

  private boolean isGeometry(String type) {
    return type.matches(POINT + "|" + "MultiPolygon");
  }


  void setPercent() {
    int numberSameStreet = 0;
    int numberSameDB = 0;
    int numberSameKVG = 0;
    int numberSameIndustry = 0;
    float percentStreet = 0.0;
    float percentDB = 0.0;
    float percentKVG = 0.0;
    float percentIndustry = 0.0;

    for (int i = 0; i < allCoordinatesGreen.size()-1; i++) {
      JSONArray values = allCoordinatesGreen.get(i);
      for (int j = 0; j < values.length()-1; j++) {
        numberSameStreet = checkSame(values, streetCoordinates);
        numberSameDB = checkSame(values, railDBCoordinates);
        numberSameKVG = checkSame(values, railKVGCoordinates);
        numberSameIndustry = checkSame(values, industryCoordinates);
      }
    }

    percentStreet = calculatePercent(counterStreet);
    percentDB = calculatePercent(counterRailDB);
    percentKVG = calculatePercent(counterRailKVG);
    percentIndustry = calculatePercent(counterIndustry);

    percentOfNoise.add(percentStreet);
    percentOfNoise.add(percentDB);
    percentOfNoise.add(percentKVG);
    percentOfNoise.add(percentIndustry);
  }

  int checkSame(JSONArray values, ArrayList<JSONArray> coordinates) {
    int counter = 0;

    for (int i = 0; i < values.length()-1; i++) {
      for (int j = 0; j < coordinates.size()-1; j++) {
        JSONArray coor = coordinates.get(j);
        for (int k = 0; k < coor.length(); k++) {
          try {
            if (values.get(i).equals(coor.get(k))) {
              counter++;
            }
          }
          catch(Exception e) {
          }
        }
      }
    }
    return counter;
  }


  float calculatePercent(int counter) {
    float percent = 0.0;    
    if (counterGreen != 0) {
      percent = (100 / counterGreen) * counter;
    }
    return percent;
  }

  void calculateAngle() {
    float angleValue = 3.6;
    for (int i = 0; i < angles.length; i++) {
      angles[i] = percentOfNoise.get(i) * angleValue;
    }
  }

  void createPieChart(String gruenFlaechenName) {
    setPieChart(gruenFlaechenName);
  }

  void setup() {
    size();
    noStroke();
    noLoop();  // Run once and stop

    this.addDataSet("incoming");
    System.out.println(angles.toString());
    this.setData("incoming", angles);
  }

  void draw() {
    background(0);
    this.setSize(100, 100);
    this.setView(Chart.PIE);
    this.getColor().setBackground(color(144, 238, 144));
    this.setVisible(true);
    //pieChart(300, angles);
  }

  void pieChart(float diameter, float[] data) {
    float lastAngle = 0;
    for (int i = 0; i < data.length; i++) {
      float gray = map(i, 0, data.length, 0, 255);
      fill(gray);
      arc(width/2, height/2, diameter, diameter, lastAngle, lastAngle+radians(angles[i]));
      lastAngle += radians(angles[i]);
    }
  }
}