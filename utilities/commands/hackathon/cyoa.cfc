/**
* This command will launch a Choos Your Own Adventure game
* This is how you call it:
*
* {code:bash}
* hackathon cyoa
* {code} 
* 
**/
component extends="commandbox.system.BaseCommand" {

    function run() {
        // Pull the story json file from https://github.com/blsnwbrdr/cyoa (raw text version)
        cfhttp( url="https://raw.githubusercontent.com/blsnwbrdr/cyoa/master/story.json", method="GET", result="storyJSON" );
        var story = deserializeJSON( storyJSON.fileContent );        
        command( '!clear' ).run();
        // Let the game begin!
        gameLoop( story );
        
        return;
    }
    
    function gameLoop( story, choice = "initial story" ){
        // Parse out the current scene (based on previous choice)
        var scene = story.filter( ( section )=>{
            return section.story == choice;
        })[1]; 
        // If this was the first scene, set the choice to "0" so future choices can build on that
        // This refers to the "story" key in the json.  Each scene has 2 choices, 1 and 2.  The user
        // choses and that number is appended to the current "story" key to determine the next scene to load.
        if( choice == "initial story" ) choice = "0";

        printFormattedSceneText( scene.text );

        // Is this the end?
        if( scene.text.right(7) == "THE END" ) return;        
        // No?, well prompt the next choices
        var answer = question( "What would you like to do?", [{ display: scene.button1, value: "1"},{ display: scene.button2, value: "2"}]  ).ask();
        // recurse to next scene (choice & answer, i.e. User chose second option on the first scene = "012", first option on the second scene = "0121", etc...)
        gameLoop( story, choice & answer );

        return;
    }
    
    function question( string question, array options ){
      return multiselect()
              .setQuestion( question )
              .setOptions( options )
                  .setRequired( true )
                  .setMultiple( false );
    }

    function printFormattedSceneText( text ){
        text = text.replaceNoCase('<br>',chr(999),'all');
        text.listToArray(chr(999)).each( (line)=>{
            if( line == "THE END"){
            gameOverASCII();                        
                return;       
            }
            print.boldGreenLine( line ).toConsole();            
        });
        return;
    }

    function gameOverASCII(){
        var image = [
            '                                                                                                    '
            ,'                                         ``.--:::::--.`                                             '
            ,'                                    `-/+ossssssssssssssso/:.`                                       '
            ,'                                 ./osssssssssssssssssssssssss+:`                                    '
            ,'                              `:osssssssssssssssssssssssssssssss+-                                  '
            ,'                             :osssssssssso//:-..````..-::/+ssssssso-                                '
            ,'                           .+ssssssss+:.`                  `.:+ossss+////:--.`                      '
            ,'                          -ossssss+-`                          `-+ssssssssssoo+/-`                  '
            ,'                         :ssssso/.           THE END!             `:osss+ossssssso+-`               '
            ,'                        .sssss/.                                    `/ss/`.:+osssssso:`             '
            ,'                        .-:/+-              Credits:                  .+s.   `-+sssssso-            '
            ,'                 .-:/++++/:-.`               Programmers:              `/+      -+ssssss/           '
            ,'              .:oosssssso+++//:.              * Abram Adams              /`      `:ssssss:          '
            ,'            `/ossssso/-``     ``                                         ``        :ssssss.         '
            ,'           .ossssso:`                                                               /sssss:         '
            ,'          .osssss+`                          Story:                                 .sssss/         '
            ,'          +sssss+`                            * https://github.com/blsnwbrdr/cyoa   `sssss:         '
            ,'          ssssss.                                                                   .sssso`         '
            ,'          osssss`                                                                   /ssss-          '
            ,'          :sssss`                   ``````...````                                  :ssso-           '
            ,'          `+ssss/            ``.-::///++++++++++//:-.`                           `/sss+.            '
            ,'           `/ssss:       `.://++++++++////////////++++/-.`                      -+so+.              '
            ,'             -+oss+.   ./++++++///:-.......```````.-://+++/:-..``             ./o+:.                '
            ,'               .:+oo/-``.///:-.``.-/++ooooooo++//:-````.-:///+++//::--...`````..`                   '
            ,'                  `..--.  `  ./+osoo+/:-..````  `````       ``..--::://////::-..`                   '
            ,'                             ./o+:.`                                                                '
            ,'                               `                                                                    '
            ,'    `-::::::::. -::::::::-`  `:::`    `::: `:::      ::: `:::         .::-     .::-   .-::::::::-   '
            ,'   .++/-------. /++:----/++-  .++/`  `/++. `+++     `+++`.+++         -++:     .++/ `/++:--------   '
            ,'   :++-         /++-.....+++   -++/``/++.  `+++     `+++`.+++         -++:     .++/ -+++////////:   '
            ,'   -++/```````  /++//////+++    -++//++-   `+++.`````+++``+++.``````` .++/`````-++/ `.......-+++-   '
            ,'    -/++++++++- /++.    `+++     :++++:     `:/+++++++++` .:++++++++/  .:+++++++++/ -+++++++++:-    '
            ,'                                                                                                    '
            ,'                                                                                                    '
        ];
        
        image.each( (line)=>{
            print.boldNavyTextOnWhiteBackgroundLine( line );
        });

    }
}
