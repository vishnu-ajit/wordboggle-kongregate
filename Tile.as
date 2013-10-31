package  
{
	import flash.events.*;
	import flash.display.MovieClip;
	import flash.filters.GlowFilter;
	
	public dynamic class Tile extends MovieClip
	{
		var tileAlphabetsArray:Array;
		var tileValuesArray:Array;
		
		public function Tile() 
		{
			tileAlphabetsArray = new Array("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z");
			tileValuesArray = new Array(1,3,3,2,1,4,2,4,1,8,5,1,3,1,1,3,10,1,1,1,1,4,4,8,4,10);
			this.addEventListener(MouseEvent.CLICK,mouseClickListener);
			
			// constructor code
		}
		public function setAlphabet(char:String)
		{
			this.txtAlphabet.text = ""+char;
			var index:int = tileAlphabetsArray.indexOf(char);
			var val:int = tileValuesArray[index];
			this.txtValue.text = ""+val;
		}
		public function removeListeners()
		{
			this.removeEventListener(MouseEvent.CLICK,mouseClickListener);
		}
		public function mouseClickListener(evt:MouseEvent)
		{
			if(this.filters.length > 0)//clicked on already selected tile
			{
				clearAllTileProperties();
				return;
			}
			   
			var glow:GlowFilter = new GlowFilter(0x00aa72,1.0,7.0,7.0,4,3);
			if(Main.currentI == -1 && Main.currentJ == -1)
			{
				Main.currentI = this["i"];
				Main.currentJ = this["j"];
				this.filters = [glow];
				Main.selectedTilesArray.push(this);
				return;
			}
			else
			{
				if(Main.currentI == this["i"] && Main.currentJ == this["j"])
				{
					trace("clicked on same tile");
					this.filters = [];
					var t:Tile = Main.selectedTilesArray.pop();
					t["i"] = -1;
					t["j"] = -1;
					if(Main.selectedTilesArray.length > 0 )//there is one or more tile selected
					{
						var topTileIndex:int = Main.selectedTilesArray.length - 1;
						var tileOnTop:Tile = Main.selectedTilesArray[topTileIndex];
						Main.currentI = tileOnTop["i"];
						Main.currentJ = tileOnTop["j"];
						
						return;
					}
					else
					{
						clearAllTileProperties();
						return;
					}
					
				}
				
				
				var absI:int = Math.abs(this["i"] - Main.currentI);
				var absJ:int = Math.abs(this["j"] - Main.currentJ);
				
				if(absI > 1 || absJ > 1)//is not a neighbour
				{
					clearAllTileProperties();
					return;
				}
				else
				{
					this.filters = [glow];
					Main.selectedTilesArray.push(this);
					Main.currentI = this["i"];
					Main.currentJ = this["j"];
					return;
				}
				
				
			}
			
			
			
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
		

	}
	
}
