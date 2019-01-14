/**
* This command will launch a Choose Your Own Adventure game
* This is how you call it:
*
* {code:bash}
* hackathon cyoa --voice
* {code} 
* 
**/
component extends="commandbox.system.BaseCommand" {
   /**
     * docker up
     *
     * @voice.hint True tells CYOA to voice the text as well as display
    */
    function run( boolean voice = false ) {
        this.voice = voice;
        this.gameComplete = false;

        variables.story = deserializeJSON( fileRead( 'assets/stories/spaceFight.json' ) );        
        command( '!clear' ).run();
        // Let the game begin!
        gameLoop( story );
        
        return;
    }

    function gameLoop( story = variables.story, choice = "initial story" ){
        // Parse out the current scene (based on previous choice)
        var scene = story.filter( ( section )=>{
            return section.story == choice;
        });

        scene = scene.len() ? scene[1] : {};
        this.gameComplete = isGameComplete( story, scene, choice );
        

        if ( scene.image.len() )
            renderSceneImage( scene.image );

        // If this was the first scene, set the choice to "0" so future choices can build on that
        // This refers to the "story" key in the json.  Each scene has 2 choices, 1 and 2.  The user
        // choses and that number is appended to the current "story" key to determine the next scene to load.
        if( choice == "initial story" ) choice = "0";

        printFormattedSceneText( scene.text );
        
        if( this.gameComplete )
            return endGame( scene );

        // No?, well prompt the next choices
        var answer = question( "What would you like to do?", [{ display: cleanString( scene.button1 ), value: "1"},{ display: cleanString( scene.button2 ), value: "2"}]  );
        // recurse to next scene (choice & answer, i.e. User chose second option on the first scene = "012", first option on the second scene = "0121", etc...)
        gameLoop( story, choice & answer );

        return;
    }
    

    function endGame( scene ){
        
        if( scene.success ){
            say( "YOU WIN!");
            renderSceneImage( 'images/success.png' )
        } else {
            say( "YOU LOSE!");
            renderSceneImage( 'images/failure.png' )
        }

        var playAgain = question( "That's it! You want to do it again?", [{ display: "I have nothing better to do! YES! Let's play!!!", value: "1"},{ display: "Time for standup - no time!", value: "0"}]  );
        
        if( playAgain ){
            return gameLoop();
        }

        gameOverASCII();
    }

    function isGameComplete( story, struct currentScene, selectedChoice ){

        if ( !currentScene.len() )
            return true;

        if( currentScene.display == 'none' )
            return true;

        return false;

    }

    function sayQuestion( question, options ){
        say( cleanString( question ) );
        var speakOptions = options.reduce( (prev,cur)=>{
            prev.append( cleanString( cur.display ) );
                return prev;
        }, []).toList(" or ");
        say( speakOptions );
    }

    function say( text ){
        if( this.voice )
            command('!say "#cleanString( text )#"').run();
    }

    function question( string question, array options ){
        sayQuestion( question, options );
        return multiselect()
                    .setQuestion( question )
                    .setOptions( options )
                    .setRequired( true )
                    .setMultiple( false ).ask();
    }
    function cleanString( text ){
        return text
            .reReplace("<[^>]*>", "","all")
            .reReplace("&##39;", '"',"all")
            .reReplace("&##34;", '"',"all");
    }
    function printFormattedSceneText( text ){
        var formattedText = cleanString( text.replaceNoCase('<br>',chr(999),'all') );
        formattedText.listToArray(chr(999)).each( (line)=>{
            print.boldGreenLine( line ).toConsole();            
        });
        say( cleanString( text ) );

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
            ,'              .:oosssssso+++//:.              * Timothy Farrar            /`      `:ssssss:         '
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

    function renderSceneImage( path ){

        var uniqueImagePath = getTempDirectory() & createUUID() & "." & listLast( path, "." );
       
        fileCopy( 'assets/' & path, uniqueImagePath );

        command( 'ImageToASCII' )
            .params( uniqueImagePath ).run();

    }

}
