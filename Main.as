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
		private var totalTimeAllotted:Number = 1 * 60 ;//2 minutes
		private var gameTimer:Timer = new Timer(1000,60);
		private var tileAlphabets= new Array("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z");
		private var tileValues= new Array(1,3,3,2,1,4,2,4,1,8,5,1,3,1,1,3,10,1,1,1,1,4,4,8,4,10);	
		public var gameScore:int = 0;
		private var gameusedTilesArray:Array = new Array();
		
		public function Main() 
		{
			
			
			// constructor code
		}
		
		private function startGame()
		{
			
			trace('kongregate:'+kongregate);
			timeElapsed = 0;
			gameScore = 0;
			gameusedTilesArray = new Array();
			gameTimer = new Timer(1000,60);
			gameTimer.removeEventListener(TimerEvent.TIMER,gameTimerListener);
			gameTimer.addEventListener(TimerEvent.TIMER,gameTimerListener);
			gameTimer.start();
			timeRemaining = totalTimeAllotted;
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
			mcFoundWords["wordsCounter"] = 0;
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
			var foundWord:String="";
			
			for(var i:int = 0; i < selectedTilesArray.length;i++)
			{
				var selectedTile:MovieClip = selectedTilesArray[i];				
				foundWord += selectedTile.txtAlphabet.text;
			}
			if(foundWord.length == 0)
			{
				return;
			}
			var mcFoundWord:FoundWord = new FoundWord();
			
			mcFoundWords.addChild(mcFoundWord);
			mcFoundWord["txtFoundWord"].text = foundWord;
			mcFoundWord.x = 10;
			mcFoundWord.y = mcFoundWord.height * mcFoundWords["wordsCounter"] + 5 *  mcFoundWords["wordsCounter"];
			mcFoundWord.name = "mcFoundWord"+mcFoundWords["wordsCounter"];
			//mcFoundWord.validate();
			if(myDictionary.isValid(foundWord)==true)
			{
				trace('word is valid');
				var tick:mcCorrect = new mcCorrect();
				mcFoundWords.addChild(tick);
				tick.x = 150
				tick.y = mcFoundWord.y;
				mcFoundWord["tick"] = tick;;
				var isWordRepeated:Boolean = false;
				for(var c:int = 0; c < mcFoundWords["wordsCounter"]; c++)
				{
					var checkWord:MovieClip = mcFoundWords.getChildByName("mcFoundWord"+c) as MovieClip;
					if(!checkWord)//word is not previously present in list, so calculate score
					{
						
						continue;
					}
					var wordInList:String = checkWord["txtFoundWord"].text ;
					if(foundWord == wordInList)
					{
						wrongTimer = new Timer(1000,0);
						wrongTimer.removeEventListener(TimerEvent.TIMER,wrongTimerListener);
						wrongTimer.addEventListener(TimerEvent.TIMER,wrongTimerListener);
						wrongTimer.start();
						currentWrong = mcFoundWord["tick"];
						currentFoundWord = mcFoundWord;
						trace('started wrong timer');
						mcFoundWords["wordsCounter"] -= 1;
						isWordRepeated = true;
					}
				}
				if(isWordRepeated == false)
				{
					trace('word is input for the first time, calculating score');
					calculateScore(foundWord);
				}
				
			}
			else
			{
				trace('word is invalid');
				var wrong:mcWrong = new mcWrong();
				mcFoundWords.addChild(wrong);
				wrong.x = 150;
				wrong.y = mcFoundWord.y;
				wrongTimer = new Timer(1000,0);
				wrongTimer.removeEventListener(TimerEvent.TIMER,wrongTimerListener);
				wrongTimer.addEventListener(TimerEvent.TIMER,wrongTimerListener);
				wrongTimer.start();
				currentWrong = wrong;
				currentFoundWord = mcFoundWord;
				trace('started wrong timer');
				mcFoundWords["wordsCounter"] -= 1;
			}
			for(var c:int = 0; c < selectedTilesArray.length;c++)
			{
				selectedTilesArray[c].filters=[];
				
			}
			selectedTilesArray.splice(0);
			currentI = -1;
			currentJ = -1;
			mcFoundWords["wordsCounter"] += 1;		
		}
		function wrongTimerListener(evt:TimerEvent)
		{
			trace(' wrong timer completed, starting alpha zeroing');
			Tweener.addTween(currentWrong,{alpha:0,time:0.5,transition:"linear"});
			Tweener.addTween(currentFoundWord,{alpha:0,time:0.5,transition:"linear"});
			
			this.removeEventListener(TimerEvent.TIMER,wrongTimerListener);
			
		}

	}
	
}
