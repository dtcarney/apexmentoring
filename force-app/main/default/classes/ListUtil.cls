public class ListUtil {


    public static List<Integer> getFirstThreeElements (List<Integer> numbers){
        List<Integer> firstThreeNumbers = new List<Integer>();

        Integer numbersSize = numbers.size();

        Integer indexCountSetZer0 = 3 - numbersSize;

        for(Integer i = 0;i < numbersSize; i++ ){
                firstThreeNumbers.add(numbers[i]);
            }

        Integer firstThreeNumbersSize = firstThreeNumbers.size();

        if(firstThreeNumbersSize < 3){
            for(Integer i = 0; i < indexCountSetZer0; i++ ){
                firstThreeNumbers.add(0);
            }
        }
        system.debug(firstThreeNumbers);
        return firstThreeNumbers;

    }


}
