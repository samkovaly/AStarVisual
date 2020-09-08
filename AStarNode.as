package {
	/**
	 * ...
	 * @author Xiler
	 */
	import src.Maths.MathVector;
	 
	internal final class AStarNode {
		private var _X:int;
		private var _Y:int;
		
		private var _G:int;
		private var _H:int;
		private var _F:int;
		private var _parentNode:AStarNode;
		
		private var _isOrigin:Boolean;
		
		public static const VERTICAL:uint = 10;
		
		public function AStarNode(thisNodeLocation:MathVector, targetNodeLocation:MathVector) {
			X = thisNodeLocation.x;
			Y = thisNodeLocation.y;
			H = Math.abs(X - targetNodeLocation.x) + Math.abs(Y - targetNodeLocation.y);
			G = 0;
			F = H + G;
		}
		
		public function set X(newX:int):void {
			this._X = newX;
		}
		public function get X():int {
			return this._X;
		}
		
		public function set Y(newY:int):void {
			this._Y = newY;
		}
		public function get Y():int {
			return this._Y;
		}
		
		public function set G(newG:int):void {
			this._G = newG;
		}
		public function get G():int {
			return this._G;
		}
		
		public function set H(newH:int):void {
			this._H = newH;
		}
		public function get H():int {
			return this._H;
		}
		
		public function set F(newF:int):void {
			this._F = newF;
		}
		public function get F():int {
			return this._F;
		}
		
		public function set parentNode(newParentNode:AStarNode):void {
			this._parentNode = newParentNode;
		}
		public function get parentNode():AStarNode {
			return this._parentNode;
		}
		
		public function setAsOrigin():void {
			_isOrigin = true;
		}
		public function checkIfOrigin():Boolean {
			return _isOrigin;
		}
		
		public function isThisInArray(arrayToCheck:Array):Boolean {
			for (var i in arrayToCheck) {
				if (arrayToCheck[i].X == this.X && arrayToCheck[i].Y == this.Y) {
					return true
				}
			}
			return false
		}
	}
}