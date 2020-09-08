package {
	import src.Characters.Character;
	import src.InGame.Map;
	import src.Maths.MathVector;
	/**
	 * ...
	 * @author Xiler
	 */
	public final class BaseAI {
		private static const bordersOfNode:Array = new Array(
			new MathVector( -1, 0), new MathVector(1, 0), new MathVector(0, -1), new MathVector(0, 1));
		
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const JUMP:String = "jump";
		public static const STILL:String = "still";
		
		private var _player:Character;
		private var map:Map;
		
		private var playerTileLocation:MathVector;
		
		
		
		private var openList:Array;
		private var closedList:Array;
		private var mapArray:Array;
		private var originNode:AStarNode;
		private var complete:Boolean;
		
		
		public function BaseAI(_player:Character,map:Map):void {
			this._player = _player;
			this.map = map;
			
			openList = new Array();
			closedList = new Array();
			mapArray = map.tiles;
		}
		public function get player():Character {
			return this._player;
		}
		
		public function calculatePlayerTileLocation():void {
			playerTileLocation = map.worldToTilePoint(player.groundPosition);
		}
		public function getDirection(enemy:Character):String {
			var enemyTileLocation:MathVector = map.worldToTilePoint(enemy.groundPosition);
			
			
			originNode = new AStarNode(enemyTileLocation, playerTileLocation);
			originNode.setAsOrigin();
			
			openList = [originNode];
			closedList = [];
			
			complete = false;
			var currentNode:AStarNode;
			var examiningNode:AStarNode;
			
			while (!complete) {
				
				openList.sortOn("F", Array.NUMERIC);
				currentNode = openList[0];
				closedList.push(currentNode);
				openList.splice(0, 1);
				
				for (var i in bordersOfNode) {
					examiningNode = new AStarNode(new MathVector(currentNode.X + bordersOfNode[i].x, currentNode.Y + bordersOfNode[i].y),playerTileLocation);
					//IF IT IS A NULL TILE (OPEN SPACE) THEN ADD IT TO OPENLIST
					if (map.isOpenTile(map.getTile(examiningNode.X, examiningNode.Y)) && !examiningNode.isThisInArray(closedList)) {
						if (!examiningNode.isThisInArray(openList)) {
							openList.push(examiningNode);
							examiningNode.parentNode = currentNode;
						}else {
							// STUFF TO DO WITH G THAT SWITCHES PARENTS... BUT G IS 0, SO THERE IS NO NEED... FOR NOW.
						}
						if (examiningNode.X == playerTileLocation.x && examiningNode.Y == playerTileLocation.y) {
							complete = true;
							var done:Boolean = false;
							var thisNode:AStarNode;
							thisNode = examiningNode;
							while (!done) {
								if (thisNode.checkIfOrigin()) {
									done = true;
								}else {
									thisNode = thisNode.parentNode;
								}
							}
						}
					}
				}
			}
			
			
			return STILL;
		}
	}
}