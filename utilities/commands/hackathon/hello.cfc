/**
* This command will say hello
* This is how you call it:
*
* {code:bash}
* hackathon hello 'Your name'
* {code} 
* 
**/
component {
   
    function run( required string name ) {
        
        print.boldGreenLine( "Hello #name#!" ).toConsole();
        return;
    }
    
    
}
