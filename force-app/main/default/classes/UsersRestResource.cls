
@RestResource(UrlMapping='/Users/*')
global with sharing class UsersRestResource 
{
    @HttpGet
    global static List<User> getUsers(){
        RestRequest req = RestContext.request;
        System.debug(req.params);
        List<User> users = [SELECT Id, FirstName, LastName FROM User Limit 10];
        return users;
    }

    @HttpPost
    global static String insertUser(User newUser){
        insert newUser;
        return newUser.Id;
    }


}