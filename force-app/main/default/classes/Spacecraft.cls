public with sharing class Spacecraft {
    public String model;
    public String manufacturer; 
    public Integer crewSize;
    public Boolean isLaunched;
    
    public Spacecraft() {

    }

    public Spacecraft(String model, String manufacturer, Integer crewSize){
        this.isLaunched = false;
        this.model = model;
        this.manufacturer = manufacturer;
        this.crewSize = crewSize;
    }

    public void toggleLaunchStatus(){
        this.isLaunched = !this.isLaunched;
       
    }
}