package Base.Object 
{
	import Base.ActionHandler;
	import Base.Engine;
	import Base.Etc.Util;
	/**
	 * ...
	 * @author 
	 */
	public class Scene extends ActionHandler
	{
		//public var name:String;
		//public var aliases:Vector.<Alias>;
		public var descriptionShort:String;
		public var descriptionLong:String;
		
		public var items:Vector.<Item>;
		
		public var npcs:Vector.<NPC>;
		public var neighborScenes:Vector.<Scene>;
		
		public var firstTime:Boolean = false;
		
		public var isVisible:Boolean;
		
		public var onEnter:Function = function() {};
		public var onLeave:Function = function() {};
		
		//public var character:Character;
		//public var characters:Vector.<Character>; //?
		
		public function Scene(register:Boolean = true) 
		{
			engine = Engine.inst;
			
			if (register) {
				engine.register(this);
			}
			
			init();
			setHelperActions();
		}
		
		public function init():void {
			//name = "";
			descriptionLong = "";
			descriptionShort = "";
			firstTime = false;
			items = new Vector.<Item>();
			//characters = new Vector.<Character>();
			npcs = new Vector.<NPC>();
			neighborScenes = new Vector.<Scene>();
			isVisible = true;
		}
		
		public function findItem(alias:String):Item {
			for each(var i:Item in items) {
				if (i.hasAlias(alias)) {
					return i;
				}
				var temp:Item = i.findItem(alias);
				if (temp != null) {
					return temp;
				}
			}
			
			var temp:Item = engine.character.findItem(alias);
			if (temp != null) {
				return temp;
			}
			var temp:Item = engine.character.findInventory(alias);
			if (temp != null) {
				return temp;
			}
			return null;
		}
		
		/*public function findCharacter(alias:String):Character {
			for each(var i:Character in characters) {
				if (i.hasAlias(alias)) {
					return i;
				}
			}
			return null;
		}*/
		
		public function findNPC(alias:String):NPC {
			for each(var i:NPC in npcs) {
				if (i.hasAlias(alias)) {
					return i;
				}
			}
			return null;
		}
		
		private function actionGo(command:String, match:Array) {
			if (match[2] == "") {
				engine.printLine("Go to where?");
				return;
			}
			
			var verb:String = match[1];
			var placestr:String = match[2].substr(1, int.MAX_VALUE);
			
			var place:Scene = findNeighborScene(placestr);
			if (place != null) {
				engine.setState(place, engine.character, place);
			} else {
				engine.printLine("I can't go there.");
			}
		}
		private function actionPickup(command:String, match:Array) {
			if (match[2] == "") {
				engine.printLine("Pick up what?");
				return;
			}
			
			var verb:String = match[1];
			var objname:String = match[2].substr(1, int.MAX_VALUE);
			
			var obj:Item = this.findItem(objname);
			
			if (obj.overridePickup) return;
			
			if (obj.isVisible && obj != null) {
				if (!obj.isPickable) {
					engine.printLine("I can't pick that up.");
				}
				else if (!obj.isPickedUp) {
					engine.printLine("Picked up the " + obj.name + ".");
					engine.character.addInventory(obj);
				} else {
					engine.printLine("I already got that.");
				}
			} else {
				engine.printLine("I can't find it.");
			}
		}
		
		public function setAction2(func:Function, pattern:String, ...Items):void {
			for (var i:int = 0; i < Items.length; i++) {
				var vari:String = ("\$" + (i + 1));
				pattern = Util.replaceAll(pattern, vari, "(" + (Items[i] as Item).getRegexName() + ")");
			}
			
			setAction(pattern+"$" , func);
		}
		
		public function setAction1(item:Item, pattern:String, func:Function):void {
			setAction(pattern + " (" + item.getRegexName() + ")$" , func);
		}
		
		private function actionDescribe(command:String, match:Array) {
			if (match[2] == "") {
				if (!firstTime) {
					firstTime = true;
					describe(true);
				} else {
					describe(false);
				}
			}
			else {
				var objname:String = match[2].substr(1, int.MAX_VALUE);
				var obj:Item = findItem(objname);
				var obj2:NPC = findNPC(objname);
				var obj3:Character = engine.character;
				
				if (obj == null) {
					obj = obj2;
					if (obj == null) {
						obj = obj3;
					}
				}
				if (obj == null) {
					engine.printLine("I can't find that.");
					return;
				} 
				else {
					engine.printLine(obj.fullDescription);
				}
			}
		}
		
		public function describe(long:Boolean = false):void {
			engine.printLine(name.toUpperCase());
			long ? engine.printLine(descriptionLong) : engine.printLine(descriptionShort);
			
			for each(var object:Item in items.concat(npcs)) {
				if(object.isVisible)
					engine.printLine("There is " + object.aliases[0] + " here.");
			}
			
			for each(var sc:Scene in neighborScenes) {
				if(sc.isVisible)
					engine.printLine("There is a path to " + sc.name + " here.");
			}
		}
		
		
		private function actionHelp(command:String, match:Array):void {
			engine.printLine("commands:\n\"help\": brings up this text.\n\"describe\": gives a description of your environment.\n\"describe [object_name]\": describes the specified object.\n\"inventory\": lists your inventory.\n\"take/pick up/grab [object_name]\": picks up the specified object.\n\"talk to [npc_name]\": starts talking to the npc.\n\"options\": shows the possible dialogue choices during dialogues with NPCs.\nThere are also other commands, which you can find out by guessing. They are mostly simple, so don't try too complicated stuff.");
		}
		
		private function actionTalk(command:String, match:Array):void {
			var npcName:String;
			
			try {
				npcName = match[5].substr(1, int.MAX_VALUE);
			} catch (e:*) {
				npcName = "";
			}
			
			if (command == "talk" || command == "speak") {
				engine.printLine("Bla bla bla.");
			} else if (npcName == "") {
				engine.printLine("Talk to whom?");
			} else {
				var npc:NPC = findNPC(npcName);
				if (npc != null) {
					npc.startChat();
				} else {
					engine.printLine("I can't find it.");
				}
			}
		}
		
		private function actionInventory(command:String, match:Array):void {
			engine.character.printInventory();
		}
		
		private function setHelperActions():void {
			setAction("(grab|pick up|take)(.*)", actionPickup);
			setAction("(describe|look at)(.*)", actionDescribe);
			setAction("help$", actionHelp);
			setAction("inventory$", actionInventory);
			setAction("(talk|speak)(( (to|with)(.*))|)", actionTalk);
			setAction("(go to|walk to)(.*)", actionGo);
		}
		
		
		
		public function addItem(...Items):void {
			for each(var item:Item in Items) {
				item.remove();
				items.push(item);
				item.owner = this;
			}
		}
		public function removeItem(item:Item):void {
			if(Util.remove(items, item))
				item.owner = null;
		}
		
		/*public function addCharacter(...Characters):void {
			for each(var item:Character in Characters) {
				characters.push(item);
				item.owner = this;
			}
		}*/
		/*public function removeCharacter(character:Character):void {
			if(Util.remove(characters, character))
				character.owner = null;
		}*/
		
		public function addNPC(...Npcs):void {
			for each(var item:NPC in Npcs) {
				npcs.push(item);
				item.owner = this;
			}
		}
		
		public function removeNPC(npc:NPC):void {
			if(Util.remove(npcs, npc))
				npc.owner = null;
		}
		
		public function addNeighborScene(...Scenes):void {
			for each(var item:Scene in Scenes) {
				neighborScenes.push(item);
			}
		}
		public function removeNeighborScene(scene:Scene):void {
			Util.remove(neighborScenes, scene);
		}
		public function findNeighborScene(name:String):Scene {
			for each(var s:Scene in this.neighborScenes) {
				if (s.hasAlias(name)) {
					return s;
				}
			}
			return null;
		}
	}

}