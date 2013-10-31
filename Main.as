package  
{
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import caurina.transitions.Tweener;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public dynamic class Main extends MovieClip
	{
		private var boggledTiles:Array;
		public static  var currentI:int = -1;
		public static var currentJ:int = -1;
		public static var selectedTilesArray:Array;
		private var myDictionary:MyDictionary;
		private var gameHasToBegin:Boolean = false
		
		private var wrongTimer:Timer;
		private var currentWrong:MovieClip;
		private var currentFoundWord:MovieClip;
		private var timeElapsed:Number=0;
		private var timeRemaining:Number;
		private var totalTimeAllotted:Number = 3 * 60 ;//2 minutes
		private var gameTimer:Timer = new Timer(1000,60);
		private var tileAlphabets= new Array("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z");
		private var tileValues= new Array(1,3,3,2,1,4,2,4,1,8,5,1,3,1,1,3,10,1,1,1,1,4,4,8,4,10);	
		public var gameScore:int = 0;
		private var gameusedTilesArray:Array = new Array();
		private var addedWords:Array = new Array();
		private var foundWordsAndTicksArray:Array = new Array();
		private var correctWords:int = 0;
		private var mcFoundWord:FoundWord;
		private var foundWord:String="";
		private var wrong:mcWrong;
		public function Main() 
		{
			
			
			// constructor code
		}
		private function submitscoreclickListener(evt:MouseEvent)
		{
			
			kongregate.scores.submit( gameScore );
			unloadScene();
			gotoAndPlay(1,"welcome");
		}
		
		private function startGame()
		{
			if(gameMode == "TIMED")
			{
				timeElapsed = 0;
				gameTimer = new Timer(1000,180);
				gameTimer.removeEventListener(TimerEvent.TIMER,gameTimerListener);
				gameTimer.addEventListener(TimerEvent.TIMER,gameTimerListener);
				gameTimer.start();
				timeRemaining = totalTimeAllotted;
				mcSubmitScore.visible = false;
			}
			else
			{
				if(gameTimer)
				{
					gameTimer.removeEventListener(TimerEvent.TIMER,gameTimerListener);
				}
				mcSubmitScore.visible = true;
				mcSubmitScore.addEventListener(MouseEvent.CLICK,submitscoreclickListener);
				
				
			}
			trace('kongregate:'+kongregate);
			
			gameScore = 0;
			gameusedTilesArray = new Array();
			
			selectedTilesArray = new Array();
			var settings:TileSettings = new TileSettings();
			myDictionary = new MyDictionary();
			settings.init();
			boggledTiles = new Array();
			boggledTiles = settings.getBoggledTiles();
			
			var loopIndex:int =-1;
			for(var i:int = 0; i < 5; i++)
			{
				for(var j:int = 0; j < 5; j++)
				{
					++loopIndex;
					var tile:MovieClip = boggledTiles[loopIndex];
					this.addChild(tile);
					gameusedTilesArray.push(tile);
					tile.x = 10+ j * tile.width + j * 5;
					tile.y = 10+ i* tile.height + i * 5;
					
				}
			}
			correctWords=0;
			mcEnterWord.addEventListener(MouseEvent.CLICK,wordEnteredListener);
			mcCancelWord.addEventListener(MouseEvent.CLICK,wordCancelledListener);
		}
		function calculateScore(foundWord:String)
		{
			var wordscore:int = 0;
			for(var i:int = 0; i < foundWord.length; i++)
			{
				var char:String = foundWord.charAt(i);
				var index:int = tileAlphabets.indexOf(char);
				var score:int = tileValues[index];
				wordscore += score;
			}
			gameScore += wordscore;			
			txtScore.text = ""+gameScore;
			var wordlength:int = foundWord.length;
			if(wordlength >= 4)
			{
				kongregate.stats.submit( "lengthy-word", wordlength )
			}
			
		}
		function gameTimerListener(evt:TimerEvent)
		{
			timeRemaining -= 1;
			var timeLeft:String = "";
			var sec:int = timeRemaining%60;
			var min:int = timeRemaining/60;
			timeLeft = "0"+min+":"+sec;
			if(sec<10)
			{
				timeLeft = "0"+min+":0"+sec;
			}
			txtTimeRemaining.text = timeLeft;
			if(timeRemaining <= 0 )
			{
				gameTimer.removeEventListener(TimerEvent.TIMER,gameTimerListener);
				
				unloadScene();
				kongregate.scores.submit( gameScore );
				gotoAndPlay(1,"welcome");
				
			}
		}
		function unloadScene()
		{
			gameTimer.removeEventListener(TimerEvent.TIMER,gameTimerListener);
			mcEnterWord.removeEventListener(MouseEvent.CLICK,wordEnteredListener);
			mcCancelWord.removeEventListener(MouseEvent.CLICK,wordCancelledListener);
			for(var i:int = 0; i < gameusedTilesArray.length; i++)
			{
				var tile = gameusedTilesArray[i];
				if(tile)
				{
					tile.parent.removeChild(tile);
				}
			}
		}
		function wordCancelledListener(evt:MouseEvent)
		{
			clearAllTileProperties();
		}
		function clearAllTileProperties()
		{
			for(var i:int = 0; i < Main.selectedTilesArray.length;i++)
			{
				Main.selectedTilesArray[i].filters=[];
				Main.selectedTilesArray[i]["i"] = -1;
				Main.selectedTilesArray[i]["j"] = -1;
				
			}
			Main.selectedTilesArray.splice(0);
			Main.currentI = -1;
			Main.currentJ = -1;
		}
		
		public function wordEnteredListener(evt:MouseEvent)
		{
			
			for(var i:int = 0; i < selectedTilesArray.length;i++)
			{
				var selectedTile:MovieClip = selectedTilesArray[i];				
				foundWord += selectedTile.txtAlphabet.text;
			}
			if(foundWord.length == 0)
			{
				return;
			}
			mcFoundWord = new FoundWord();
			this.addChild(mcFoundWord);
			
			
			mcFoundWord["txtFoundWord"].text = foundWord;
			mcFoundWord.x = 680;
			mcFoundWord.y = 200;
			mcFoundWord.name = "mcFoundWord"+correctWords;
			//mcFoundWord.validate();
			if(myDictionary.isValid(foundWord)==true)
			{
				
				var isWordRepeated:Boolean = false;
				for(var c:int = 0; c <correctWords; c++)
				{					
					var isWordAlreadyInList:int = addedWords.indexOf(foundWord);
					if(isWordAlreadyInList != -1)//word already used.
					{
						
						Tweener.addTween(mcFoundWord,{x:-25,y:-250,scaleX :0.4,scaleY: 0.4,alpha : 0,time:3,transition:"linear",onComplete:wordTravelledOutofScreen});
						trace('started wrong timer');
						correctWords -= 1;
						isWordRepeated = true;
						
					}
					
				}
				if(isWordRepeated == false)
				{
					addedWords.push(foundWord);
					Tweener.addTween(mcFoundWord,{x:txtScore.x,y:txtScore.y,scaleX :0.4,scaleY: 0.4,alpha : 0,time:1,transition:"linear",onComplete:wordTravelledTillScoreTextbox});
					trace('word is input for the first time, calculating score');
					foundWordsAndTicksArray.push(mcFoundWord);
				}
				
			}
			else
			{
				trace('word is invalid');
				Tweener.addTween(mcFoundWord,{time:1.8,alpha:0.05,transition:"linear",onComplete:wordTravelledOutofScreen});
				wrong = new mcWrong();
				this.addChild(wrong);
				mcFoundWord.scaleX *= 3;
				mcFoundWord.scaleY *= 3;
				mcFoundWord.x -= 100;
				Tweener.addTween(wrong,{alpha:0.05,time:1.8,transition:"linear"});
				wrong.scaleX *= 3;
				wrong.scaleY *= 3;
				wrong.x = mcFoundWord.x + foundWord.length * 15;
				wrong.y = mcFoundWord.y + 10;
				
				
				correctWords -= 1;
			}
			for(var c:int = 0; c < selectedTilesArray.length;c++)
			{
				selectedTilesArray[c].filters=[];
				
			}
			selectedTilesArray.splice(0);
			currentI = -1;
			currentJ = -1;
			correctWords += 1;
			var totalWordsNow:int = correctWords;
			
			if( totalWordsNow >= 3 )
			{
				for(var i:int = 0; i < foundWordsAndTicksArray.length;i++)
				{
					var mc = foundWordsAndTicksArray[i] as MovieClip;
					if(mc)
					{
						mc.parent.removeChild(mc);
					}
				}
				correctWords=0;
				
			}
		}
		function wordTravelledOutofScreen()
		{
			if(mcFoundWord)
			{
				mcFoundWord.parent.removeChild(mcFoundWord);
				mcFoundWord = null;
			}
			foundWord="";
			wrong.parent.removeChild(wrong);
		}
		function wordTravelledTillScoreTextbox()
		{
			trace('travel complete');
			if(mcFoundWord)
			{
				mcFoundWord.parent.removeChild(mcFoundWord);
				mcFoundWord = null;
			}
			
			calculateScore(foundWord);
			foundWord="";
		}
		
		function wrongTimerListener(evt:TimerEvent)
		{
			
			Tweener.addTween(currentWrong,{alpha:0,time:0.5,transition:"linear"});
			Tweener.addTween(currentFoundWord,{alpha:0,time:0.5,transition:"linear"});
			
			this.removeEventListener(TimerEvent.TIMER,wrongTimerListener);
			
		}

	}
	
}
