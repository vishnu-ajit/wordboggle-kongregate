package  
{
	
	public class TileSettings 
	{

		var tileAlphabetsArray:Array;
		var tileValuesArray:Array;
		
		public function TileSettings() 
		{
			tileAlphabetsArray = new Array("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z");
			tileValuesArray = new Array(1,3,3,2,1,4,2,4,1,8,5,1,3,1,1,3,10,1,1,1,1,4,4,8,4,10);
			
			
			
			// constructor code
		}
		public function init()
		{
			for(var i:int = 0; i < 26; i++)
			{
				var tile:Tile = new Tile();
				tile.txtAlphabet.text = tileAlphabetsArray[i];
				tile.txtValue.text = tileValuesArray[i];					
				
			}
			
		}
		public function find25():Array
		{
			var vowelsArray:Array = new Array("A","E","I","O","U");
			var boggledArray:Array = new Array();
			for(var c:int = 0; c < 3; c++)
			{
				var randIndex:int = Math.round(Math.floor(Math.random()*5));
				var randVowel = vowelsArray[randIndex];
				boggledArray.push(randVowel);
			}
			for(var i:int = 0;i<22;i++)
			{
				var randNum:uint = Math.round(Math.floor(Math.random()* 26) ) ;
				boggledArray.push(randNum);
			}
			
			boggledArray = shuffle(boggledArray);
			
			return boggledArray;
		}
		public function shuffle(boggledArray):Array
		{
			
			for(var i:int = 0; i < 100; i++)
			{
				
				var randIndex :int = Math.round(Math.random()*boggledArray.length);
				var splicedValue = boggledArray[randIndex];
				boggledArray.splice(randIndex,1);
				boggledArray.push(splicedValue);
			}
			return boggledArray;
		}
		
		public function getBoggledTiles():Array
		{			
			var boggledArray:Array = find25();
			var boggledTilesArray:Array = new Array();
			var loopIndex:int = -1; 
			for(var i:int = 0; i <5;i++)
			{
				for(var j:int = 0; j < 5; j++)
				{
					++loopIndex;
					var tileIndex:int = boggledArray[loopIndex];
					var tile:Tile = new Tile();
					tile.txtAlphabet.text = tileAlphabetsArray[tileIndex];
					tile.txtValue.text = tileValuesArray[tileIndex];	
					boggledTilesArray.push(tile);
					tile.name = "tile_"+i+"_"+j;
					tile["i"] = i;
					tile["j"] = j;
				}
			}
			return boggledTilesArray;
			
		}

	}
	
}
