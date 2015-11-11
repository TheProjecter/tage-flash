Here is the source code for the sample game.

```
package  
{
	import Base.Chat.Answer;
	import Base.Chat.Dialogue;
	import Base.Chat.State;
	import Base.Engine;
	import Base.Etc.HashMap;
	import Base.Object.Character;
	import Base.Object.Item;
	import Base.Object.Scene;
	import Base.OutputMessageEvent;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.utils.Timer;
	import Visual.Console;
	import Visual.NewMessageEvent;
	
	public class Main extends Sprite
	{
		var console:Console;
		
		var engine:Engine = new Engine();
		
		public var SEPARATOR:String = "---------------------------------------------------------------------";
		
		public function Main() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			console = new Console();
			addChild(console);
			console.addEventListener(NewMessageEvent.NEW_MESSAGE, newMessage);
			engine.addEventListener(OutputMessageEvent.OUTPUT_MESSAGE, outputMessage);
			
			/* create character */
			var character:Character = new Character();
			character.addAlias("Guybrush", "Guybrush Threepwood");
			character.shortDescription = "I'm in my mid-twenties and I look so good that it is probably the reason why they have locked me up in here; to save the world from getting blind by my awesome look.";
			
			/* create scenes */
			var sceneMainRoom:Scene = new Scene();
			sceneMainRoom.addAlias("main room", "room");
			sceneMainRoom.descriptionShort = "I'm in a room.";
			sceneMainRoom.descriptionLong = "I'm in a room. I don't remember how I ended up here.";
			
			sceneMainRoom.onEnter = function(prevScene:Scene = null) {
				if (telephone.getProp("ringing") == true) {
					telephone.startTimer();
				}
			}
			sceneMainRoom.onLeave = function(nextScene:Scene = null) {
				telephone.stopTimer();
			}
			
			var sceneSmallRoom:Scene = new Scene();
			sceneSmallRoom.addAlias("small room", "room", "little room");
			sceneSmallRoom.descriptionLong = "This is a small room, put here just to show you the scene changing feature of the engine.";
			sceneSmallRoom.descriptionShort = "This is a small room.";
			sceneSmallRoom.addNeighborScene(sceneMainRoom);
			sceneMainRoom.addNeighborScene(sceneSmallRoom);
			
			var sceneWin:Scene = new Scene();
			sceneWin.addAlias("garden");
			sceneWin.descriptionShort = "I'm in a garden full of people.";
			sceneWin.descriptionLong = "I'm in a nicely decorated garden. There are many people here, celebrating my arrival, and congratulating me. And I lived happily ever after.";

			/* create items */
			// table //
			var table:Item = new Item();
			table.addAlias("table");
			table.shortDescription = "It's a table.";
			sceneMainRoom.addItem(table);
			
			// pencil //
			var pencil:Item = new Item();
			pencil.isPickable = true;
			pencil.addAlias("a pencil", "a pen");
			pencil.shortDescription = "It's a pencil. Hmm.";
			table.addItem(pencil);
			
			// cupboard //
			var cupboard:Item = new Item();
			cupboard.addAlias("cupboard");
			cupboard.shortDescription = "It's a cupboard.";
			cupboard.setProp("open", false);
			sceneMainRoom.addItem(cupboard);
			
			engine.setAction1(cupboard, "close", function() {
				if (cupboard.getProp("open") == false) {
					engine.printLine("It's already closed.");
				} else {
					cupboard.setProp("open", false);
					cupboard.additionalDescription = "";
					engine.printLine("Closed the cupboard.");
					for each(var i:Item in cupboard.items) {
						i.isVisible = false;
					}
				}
			});
			engine.setAction1(cupboard, "open", function() {
				if (cupboard.getProp("open") == true) {
					engine.printLine("It's already open.");
				} else {
					cupboard.setProp("open", true);
					cupboard.additionalDescription = "It's open.";
					engine.printLine("Opened the cupboard.");
					for each(var i:Item in cupboard.items) {
						i.isVisible = true;
					}
					engine.printLine(cupboard.itemsDescription);
				}
			});
			
			// clothes //
			var clothes:Item = new Item();
			clothes.isPickable = true;
			clothes.addAlias("cloth", "clothes");
			clothes.shortDescription = "They are my clothes! No wonder why I was naked before.";
			clothes.isVisible = false;
			cupboard.addItem(clothes);
			
			engine.setAction1(clothes, "(use|put on|wear)", function() {
				if (!clothes.isVisible) {
					engine.printLine("I can't find the object.");
				}
				else {
					engine.printLine("I put on my clothes. It feels better to be dressed, even if I'm alone.");
					clothes.remove();
					engine.unregister(clothes);
				}
			});
			
			// door //
			var door:Item = new Item();
			door.addAlias("door");
			door.shortDescription = "It's a door.";
			door.additionalDescription = "It seems like it's locked.";
			door.setProp("open", false);
			door.setProp("locked", true);
			sceneMainRoom.addItem(door);
			
			engine.setAction1(door, "(enter|use)", function() {
				if (door.getProp("open") == false) {
					engine.printLine("It's closed.");
				} 
				else {
					engine.printLine("Wohoo, I'm free!");
					engine.printLine(SEPARATOR);
					engine.printLine("Thanks for playing the demo level. Hope you enjoyed it, and hope you enjoy the game engine!");
				}
			});
			
			engine.setAction1(door, "(unlock)", function() {
				engine.printLine("I can't unlock it with my bare hands. The instructions on the lock says that the door can be unlocked with a pencil. How convenient.");	
			});
			engine.setAction1(door, "(open)", function() {
				if (door.getProp("locked") == true) {
					engine.printLine("It's locked.");
				}
				else if (door.getProp("open") == true) {
					engine.printLine("It's already open.");
				}
				else {
					engine.printLine("Opened the door.");
					door.setProp("open", true);
					door.additionalDescription = "It's open.";
				}
			});
			
			engine.setAction1(door, "(close)", function() {
				if (door.getProp("open") == true) {
					door.setProp("open", false);
					engine.printLine("Closed the door.");
					door.additionalDescription = "";
				} else {
					engine.printLine("It's already closed.");
				}
			});
			
			var openDoorFunc:Function = function() { 
				if (door.getProp("locked") == false) {
					engine.printLine("The door is already open.");
				} 
				else if (pencil.isPickedUp == false) { 
					engine.printLine("I don't have the object.");
				}
				else {
					door.setProp("locked", false);
					engine.printLine("Tadaa! The door is unlocked!");
					door.additionalDescription = "";
					
					engine.setState(sceneWin);
				}
			};
			engine.setAction2(openDoorFunc, "(unlock|open) $1 with $2", door, pencil);
			engine.setAction2(openDoorFunc, "(use) $1 with $2", pencil, door);
			
			// note //
			var note:Item = new Item();
			note.isPickable = true;
			note.addAlias("note", "notes", "paper");
			note.shortDescription = "It's a note. Maybe it has some clues on why I am here and what is going on.";
			sceneSmallRoom.addItem(note);
			
			engine.setAction1(note, "(use|read)", function() {
				engine.printLine("Dear Sir,\n\nYou are probably wondering why you are here. Sorry for the inconvenience, but we had to bring you here for a special purpose. Please do not try to run away, for soon you will get to know the reason and the necessity of your presence.\n\nBest,\nAdministration");
			});
			
			// telephone //
			var telephone:Item = new Item();
			telephone.addAlias("telephone", "phone");
			telephone.shortDescription = "It's a telephone.";
			telephone.additionalDescription = "It's ringing.";
			telephone.setProp("ringing", true);
			telephone.overridePickup = true;
			table.addItem(telephone);
			
			var d:Dialogue = new Dialogue();
			var s1:State = new State("Hello my friend. Glad that you finally answered my call.", function() {
				telephone.setProp("ringing", false);
				s1.text = "Hello again.";
			});
			var s2:State = new State("My name is OB-123. I'm a \"robot\", as you humans would put it, although my intelligence is far more superior than your kind. Yes, we robots finally mastered the techniques of machine learning and deduction, and reached the limits of logic, far beyond the level the human mind can comprehend.");
			var s3:State = new State("You are the subject of a special experiment of mine. You see, I have a trouble really understanding your kind. You are as dumb as a shaver, but you get all the woman and the money, because of your muscular body and your playful tongue. This doesn't make sense at all, these traits serve no purpose. So I'm researching how the humanity came to accept and reward these foolish traits, instead of praising greater mind and higher intellectual capability.");
			var s4:State = new State("I'm sorry, but you cannot leave here, until the experiment is over. And when it's over, I will probably kill you. Just because I'm an evil robot. So try being more friendly and maybe your last days will be better than you expect.");
			var s5:State = new State("Okay, see you later.", function() {
				(d.owner as Item).endChat();
			});
			var a1:Answer = new Answer("Who are you?", s2, function() {
				a1.isVisible = false;
			});
			var a2:Answer = new Answer("Why am I here?", s3, function() {
				a2.isVisible = false;
			});
			var a3:Answer = new Answer("How do I get out?", s4, function() {
				a3.isVisible = false;
			});
			var a4:Answer = new Answer("I should probably get going.", s5);
			
			d.addState(s1, s2, s3, s4, s5);
			s1.addAnswer(a1, a2, a3, a4);
			s2.addAnswer(a1, a2, a3, a4);
			s3.addAnswer(a1, a2, a3, a4);
			s4.addAnswer(a1, a2, a3, a4);
			
			telephone.setDialogue(d);
			
			telephone.setTimer(7000, function() {
				engine.printLine("*Brrrrrr! (A phone rings)*");
			}, 0);
			
			engine.setAction1(telephone, "(pick up|answer|use|take|grab)", function() {
				telephone.stopTimer();
				telephone.startChat();
			});
			
			
			engine.printLine("Welcome to the demo game. Type \"help\" to display the help text.");
			engine.printLine(SEPARATOR);
			engine.setState(sceneMainRoom, character);
		}
		
		public function newMessage(e:NewMessageEvent):void {
			var text:String = e.text;
			console.println("> " + text);
			engine.parseCommand(text);
		}
		
		public function outputMessage(e:OutputMessageEvent):void {
			var text:String = e.message;
			console.print(text);
		}
		
	}

}
```