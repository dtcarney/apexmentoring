public with sharing class SimpleListOps {

    public List<String> createFruitsList(){
        List<String> fruits = new List<String>();
        fruits.add('Apple');
        fruits.add('Banana');
        fruits.add('Orange');
        fruits.add('Mango');
        fruits.add('Strawberry');
        return fruits;
    }

    public String getElementAt(List<String> inputList, Integer index){
        Integer listSize = inputList.size();
        if(index < 0 || index >= listSize){
            return 'Invalid Index';
        }
        return inputList[index];
    }

    public List<String> getFirstAndList(List<String> inputList){

        List<String> result = new List<String>();
        if(inputList.size() >= 2){
            result.add(inputList[0]);
            result.add(inputList[inputList.size()-1]);
        }
        return result;
    }

    public List<String> appendValue(List<String> inputList, String newValue){
        List<String> result = new List<String>();
        result.add(newValue);
        return result;
    }



}