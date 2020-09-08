package  {
	import flash.display.*
	import flash.events.*
	import flash.geom.*
	import flash.utils.*
	public class Main extends MovieClip {
		private var grid:Shape;
		private var gridX:int=20
		private var gridY:int=20
		private var boxWidth:Number;
		private var boxHeight:Number;
		private var enemy:Enemy;
		private var currentNode:Object
		private var node:Object
		private var map:Array
		private var startLocal:Point=new Point(0,0)
		private var goal:Point=new Point(1,0)
		private var moveCost:Number=10
		private var openList:Array
		private var closedList:Array;
		private var path:Array;
		private var timer:Timer;
		private var time:Number=1000
		private var targetCord,startCord:Point
		private var reference:Point;
		private var specialPlace:Boolean=false;
		private var maxGrid:Number=30
		private var buttonSpace:Number=20
		private var placeString:String="start";
		private var walls:Array;
		private var alphaNumber:Number=.5
		private var speedMin:Number=10
		private var speedMax:Number=5000
		private var clickDown:Boolean;
		public function Main(){
			walls=new Array()
			reset.x=reset.width+buttonSpace
			reset.y=stage.stageHeight
			go.x=0
			go.y=stage.stageHeight
			setupButton.x=reset.x+setupButton.width+buttonSpace
			setupButton.y=stage.stageHeight
			startButton.x=setupButton.x+startButton.width+buttonSpace
			startButton.y=stage.stageHeight;
			wallButton.x=startButton.x+wallButton.width+buttonSpace
			wallButton.y=stage.stageHeight;
			goalButton.x=wallButton.x+goalButton.width+buttonSpace
			goalButton.y=stage.stageHeight;
			setupButton.addEventListener(MouseEvent.CLICK,setup)
			
			manyX.text="12"
			manyY.text="8"
			speed.text="70"
			
			startButton.addEventListener(MouseEvent.CLICK,whichPlace)
			wallButton.addEventListener(MouseEvent.CLICK,whichPlace)
			goalButton.addEventListener(MouseEvent.CLICK,whichPlace)
			stage.addEventListener(MouseEvent.MOUSE_DOWN,setClickDown)
			stage.addEventListener(MouseEvent.MOUSE_UP,setClickUp)
		}
		public function setup(event:MouseEvent) {
			clickDown=false
			time=5000-(((Number(speed.text)/20)+95)*50)
			time=Math.min(Math.max(time,speedMin),speedMax)
			gridX=Number(manyX.text)
			gridY=Number(manyY.text)
			if(gridX>maxGrid) gridX=maxGrid
			if(gridY>maxGrid) gridY=maxGrid
			specialPlace=true;
			setupButton.removeEventListener(MouseEvent.CLICK,setup)
			go.addEventListener(MouseEvent.CLICK,reload)
			reset.addEventListener(MouseEvent.CLICK,resetAll)
			openList=new Array()
			closedList=new Array()
			//A-Star algoithiam test
			boxWidth=stage.stageWidth/gridX
			boxHeight=(stage.stageHeight/gridY)*.95
			map=new Array()
			for(var y:int=0;y<gridY;y++){
				for(var x:int=0;x<gridX;x++){
					var block:MovieClip=new MovieClip()
					block.graphics.lineStyle(0)
					block.x=x*boxWidth
					block.y=y*(boxHeight)
					block.local=new Point(x,y)
					node=new Object()
					if(x==startLocal.x && y==startLocal.y){
						block.graphics.beginFill(0x00FF00,alphaNumber)
						block.graphics.drawRect(0,0,boxWidth,boxHeight)
						block.tag="start"
					}
					for(var i in walls){
						if(walls[i].x==x && walls[i].y==y){
							block.graphics.beginFill(0x000099,alphaNumber)
							block.graphics.drawRect(0,0,boxWidth,boxHeight)
							block.tag="wall"
						}
					}
					if(x==goal.x && y==goal.y){
						block.graphics.beginFill(0xFF0000,alphaNumber)
						block.graphics.drawRect(0,0,boxWidth,boxHeight)
						block.tag="goal"
					}
					if(block.tag==null){
						block.graphics.beginFill(0x191919,alphaNumber)
						block.graphics.drawRect(0,0,boxWidth,boxHeight)
						block.tag="pass"
					}
					block.addEventListener(MouseEvent.ROLL_OVER,setSpecial)
					block.addEventListener(MouseEvent.MOUSE_DOWN,setSpecialPre)
					block.addEventListener(MouseEvent.MOUSE_DOWN,setSpecial)
					addChild(block)
					node.box=block
					node.H=Math.abs(goal.x-x)+Math.abs(goal.y-y)
					node.G=0
					node.F=node.G+node.H
					map.push(node)
				}
			}
			enemy=new Enemy()
			enemy.x=startLocal.x*boxWidth+boxWidth/2-.6
			enemy.y=startLocal.y*boxHeight+boxHeight/2-.6
			addChild(enemy)
			enemy.scaleX=.35
			enemy.scaleY=.35
			for(i in map){
				if (map[i].box.local.equals(startLocal)) openList.push(map[i])
			}
		}
		public function resetAll(event:MouseEvent){
			if(event!=null){
				if(event.currentTarget==reset){
					walls=new Array()
				}
			}
			reset.removeEventListener(MouseEvent.CLICK,resetAll)
			go.removeEventListener(MouseEvent.CLICK,reload)
			setupButton.addEventListener(MouseEvent.CLICK,setup)
			for(var i in map){
				map[i].box.parent.removeChild(map[i].box)
			}
			openList=null
			closedList=null
			path=null
			map=null
			removeChild(enemy)
			enemy=null
			if(timer!=null){
				stage.removeEventListener(Event.ENTER_FRAME,update)
				timer.stop()
				timer.removeEventListener(TimerEvent.TIMER,move)
				timer=null
			}
			targetCord=null
			startCord=null
			placeString="wall"
		}
		public function whichPlace(event:MouseEvent){
			if(event.currentTarget==startButton){
				placeString="start"
			}else if(event.currentTarget==wallButton){
				placeString="wall"
			}else{
				placeString="goal"
			}
		}
		public function setClickDown(event:MouseEvent){
			clickDown=true;
		}
		public function setClickUp(event:MouseEvent){
			clickDown=false;
		}
		public function setSpecialPre(event:MouseEvent){
			clickDown=true;
		}
		public function setSpecial(event:MouseEvent){
			if(specialPlace){
				var thisBox:MovieClip=MovieClip(event.currentTarget)
				var newColor:ColorTransform=thisBox.transform.colorTransform
				if(placeString=="start" && clickDown){
					for(var i in map){
						if(map[i].box.local.equals(startLocal)){
							newColor.color=0x191919
							map[i].box.transform.colorTransform=newColor
						}
					}
					startLocal=thisBox.local
					newColor.color=0x00FF00
				}else if(placeString=="goal" && clickDown){
					for(i in map){
						if(map[i].box.local.equals(goal)){
							newColor.color=0x191919
							map[i].box.transform.colorTransform=newColor
						}
					}
					goal=thisBox.local
					newColor.color=0xFF0000
				}
				if(clickDown && placeString=="wall"){
					if(event.currentTarget.tag!="wall"){
						newColor.color=0x000099
						for(i in map){
							if(map[i].box==thisBox) walls.push(new Point(map[i].box.local.x,map[i].box.local.y))
						}
						event.currentTarget.tag="wall"
					}
					if(event.altKey){
						newColor.color=0x191919
						for(i in walls){
							if(walls[i].equals(event.currentTarget.local)) walls.splice(i,1)
							   event.currentTarget.tag="pass"
						}
					}
				}
				thisBox.transform.colorTransform=newColor
			}
		}
		public function reload(event:MouseEvent){
			resetAll(null)
			setup(null)
			pathFinder(null)
		}
		public function pathFinder(event:Event){
			openList.sortOn("F",Array.NUMERIC)
			var alreadyAdded:Boolean=false;
			var onClosed:Boolean=false;
			for(var i in map){ // up, down, left, and right
				if((openList[0].box.local.x==map[i].box.local.x && openList[0].box.local.y==map[i].box.local.y+1) ||
				   (openList[0].box.local.x==map[i].box.local.x && openList[0].box.local.y==map[i].box.local.y-1) || 
				   (openList[0].box.local.x==map[i].box.local.x+1 && openList[0].box.local.y==map[i].box.local.y) || 
				   (openList[0].box.local.x==map[i].box.local.x-1 && openList[0].box.local.y==map[i].box.local.y)){ 
					alreadyAdded=false;
					onClosed=false;
					for(var u in openList){
						if (openList[u]==map[i]) alreadyAdded=true
					}
					for(var o in closedList){
						if(closedList[o]==map[i]) onClosed=true
					}
					if (alreadyAdded==false && onClosed==false && (map[i].box.tag=="pass" || map[i].box.tag=="goal")){
						//dont touch
						var newCord:Point=new Point(map[i].box.x,map[i].box.y)
						var newCord2:Point = openList[0].box.localToGlobal(new Point(0, 0))
						map[i].G = openList[0].G + 10;
						trace(map[i].G);
						openList.push(map[i])
						openList[0].box.addChild(map[i].box)
						map[i].box.x=newCord.x-newCord2.x
						map[i].box.y=newCord.y-newCord2.y
					}
				   	if(map[i].box.tag=="goal"){
						path=new Array()
						var done:Boolean=false;
						path[0]=map[i].box
						while (done == false) {
							trace(path[path.length-1].G)
							path.push(path[path.length-1].parent)
							if (path[path.length - 1].local.equals(startLocal)) done = true
						}
					}
				}
			}
			closedList.push(openList[0])
			openList.splice(0,1)
			if(done==false){
				pathFinder(null)
			}else{
				specialPlace=false;
				timer=new Timer(time,path.length)
				timer.addEventListener(TimerEvent.TIMER,move)
				timer.start()
				stage.addEventListener(Event.ENTER_FRAME,update)
			}
		}
		public function move(event:TimerEvent){
			if(timer.currentCount==path.length){
				timer.stop()
				timer=null
				stage.removeEventListener(Event.ENTER_FRAME,update)
				resetAll(null)
				setup(null)
				specialPlace=true;
			}else{
				if(targetCord==null){
					enemy.x=startLocal.x*boxWidth+(boxWidth/2)
					enemy.y=startLocal.y*boxHeight+(boxHeight/2)
				}
				if(targetCord!=null){
					enemy.x=targetCord.x
					enemy.y=targetCord.y
				}
				reference=new Point()
				reference=path[(path.length-timer.currentCount)-1].local
				targetCord=new Point()
				startCord=new Point()
				startCord.x=enemy.x
				startCord.y=enemy.y
				targetCord.x=(reference.x*boxWidth)+(boxWidth/2)
				targetCord.y=(reference.y*boxHeight)+(boxHeight/2)
			}
		}
		public function update(event:Event){
			if(targetCord!=null){
				enemy.x+=((targetCord.x-startCord.x)/(time/20))
				enemy.y+=((targetCord.y-startCord.y)/(time/20))
			}
		}
	}
}
