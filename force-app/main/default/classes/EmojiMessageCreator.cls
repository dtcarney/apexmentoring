public class EmojiMessageCreator {

    public Map<String,String> emojiMap = new Map<String,String>{
    ':)' => '\\u263A',
    ':(' => '\\u1F600', 
    '<3' => '\\u2764'
    };

    public String replaceWithEmojis(String message){
    
     String emoji = emojiMap.get(message);
     return emoji;


    }

}