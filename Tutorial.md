# Introduction #

In this tutorial, I will try to walk you through programming a sample game with TAGE. I will try to show all the features of the game engine.

## 1. Adding the Interface and the Engine ##

First, we need an engine to simulate the game. Engine is the main component of the engine. All it does is accepting input commands as string and returning an answer as output. The output is sent by an event, rather than returning a string.

```
var engine:Engine = new Engine();
engine.addEventListener(OutputMessageEvent.OUTPUT_MESSAGE, outputMessage);
```

We also need an interface to receive input and show output. For this tutorial, I will use the Console class included in the engine.

```
console = new Console();
addChild(console);
console.addEventListener(NewMessageEvent.NEW_MESSAGE, newMessage);
```

Here are the codes for the event handlers:

```
public function newMessage(e:NewMessageEvent):void {
	var text:String = e.text;
	console.println("> " + text);
	engine.parseCommand(text);
}

public function outputMessage(e:OutputMessageEvent):void {
	var text:String = e.message;
	console.print(text);
}
```

## 2. Adding Scenes ##

Scenes are what hold objects inside and create a scenery in which the game is currently played. The player can interact with objects in the current scene.

For this demo, we will create three scenes.

```
var sceneMainRoom:Scene = new Scene();
sceneMainRoom.addAlias("main room", "room");
sceneMainRoom.descriptionShort = "I'm in a room.";
sceneMainRoom.descriptionLong = "I'm in a room. I don't remember how I ended up here.";

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
```

addAlias adds aliases (names) for the scene. the player can refer to the scene with one of these names, for example while coming to this room from another place. when the player says "go to room" or "go to main room", both commands will work.

descriptionShort is the short description that is showed when the player wants to describe the room. descriptionLong is printed the first time the player enters the room.

addNeighborScene adds a neighbor to the scene. The player can go from a scene to its neighbors.

## 3. Adding the Character ##

The game must have one character to be played. It's just an item with inventory.

```
var character:Character = new Character();
character.addAlias("me", "myself", "Guybrush", "Guybrush Threepwood");
character.shortDescription = "I'm in my mid-twenties and I look so good that it is probably the reason why they have locked me up in here; to save the world from getting blind by my awesome look.";
```

The methods and variables will be explained in the next section.

## 4. Adding Items ##

This is the longest part, so get ready. We will create items, define interactions with them, and add them to the scene.

The items can belong to a character, another item, or a scene. The interactions can belong to anything that inherits the ActionHandler class; that is Engine, Character, Item, NPC, Dialogue. The default interaction handler is the engine. The player can interact with objects in his/her inventory or in the current scene.

```
var table:Item = new Item();
table.addAlias("table");
table.shortDescription = "It's a table.";
sceneMainRoom.addItem(table);
```

The items have to be added to a scene (or to charcter's inventory) to be included in the game.

Items have short description and additional description properties; additional description is useful for changeable properties of the object, for example if a door is open you may choose to have the description "It's a door. It's open.", and if it's closed, it will simply be "It's a door. It's closed". So the idea is, shortDescription = "It's a door.", and additionalDescription = "It's closed.". When the player opens the door, you simply assign additionalDescription to "It's open."

```
var pencil:Item = new Item();
pencil.isPickable = true;
pencil.addAlias("a pencil", "a pen");
pencil.shortDescription = "It's a pencil. Hmm.";
table.addItem(pencil);	

var note:Item = new Item();
note.isPickable = true;
note.addAlias("note", "notes", "paper");
note.shortDescription = "It's a note. Maybe it has some clues on why I am here and what is going on.";
table.addItem(note);	
```

isPickable property defines whether the object may be picked up by the player. We will come to commands later.

Here you see we add objects to another object, in this example we add a note and a pen to the table. So, these objects "belong to" table; they are described when the player looks at the table, they aren't described in the general description of the scene.

```
var cupboard:Item = new Item();
cupboard.addAlias("cupboard");
cupboard.shortDescription = "It's a cupboard.";
sceneMainRoom.addItem(cupboard);
cupboard.setProp("open", false);
```

setProp and getProp are two functions to add custom properties to your object, for customizing them. Here we use a custom property called "open", to detect whether the cupboard is opened or not.

```
var clothes:Item = new Item();
clothes.isPickable = true;
clothes.addAlias("cloth", "clothes");
clothes.shortDescription = "They are my clothes! No wonder why I was naked before.";
clothes.isVisible = false;
cupboard.addItem(clothes);
```

Here we set another property of items, isVisible. If an object is invisible, the player won't see it in descriptions. For example when a cupboard is closed, the objects inside it should be invisible.

```
var door:Item = new Item();
door.addAlias("door");
door.shortDescription = "It's a door.";
door.additionalDescription = "It seems like it's locked.";
door.setProp("open", false);
door.setProp("locked", true);
sceneMainRoom.addItem(door);

var telephone:Item = new Item();
telephone.addAlias("telephone", "phone");
telephone.shortDescription = "It's a telephone.";
telephone.additionalDescription = "It's ringing.";
telephone.setProp("ringing", true);
telephone.overridePickup = true;
table.addItem(telephone);

telephone.setTimer(7000, function() {
	engine.printLine("*Brrrrrr! (A phone rings)*");
}, 0);
```

Here we have a funny thing called overridePickup. Since the "pick up x" command is predefined in the engine, this variable is needed to override the engine's behaviour of pick up command. I use it here because "pick up phone" here means answering it, rather than actually picking it up. All the objects are unpickable by default, by the way.

We also set the timer delay and function of the timer of the item. Each item has a timer that you can use for your special purposes. Here we use it to simulate the ringing of the phone. Engine class has a function called startAllTimers(scene) and stopAllTimers(scene), which starts and stops all the timers in a scene. If you don't give any scene, all the timers are started or stopped, regardless of their scene. These functions include the timer of the character.

## 5. Adding Custom Actions ##

Actions are what define the game interaction. The player types in commands, such as "pick up/take x" or "look at/describe y" or "walk to/go to z". Besides, you can also allow custom commands, anything you want. You simply register your commands and their callback functions to the engine, and you are good to go. Here I will try to explain how it works. There are two methods, engine.setAction1 and engine.setAction2, the former being simpler than the latter.

Note: You can spare lots of time by using regex in your commands. The callback functions are called with (command:String, match:Array) pair, command being the formatted command of the player (useless spaces are removed, the command is made all lower case, the articles are removed, and so on), and match being the match array for the regex result matched with the player's command.

```
engine.setAction1(note, "(use|read)", function() {
	engine.printLine("Dear Sir,\n\nYou are probably wondering why you are here. Sorry for the inconvenience, but we had to bring you here for a special purpose. Please do not try to run away, for soon you will get to know the reason and the necessity of your presence.\n\nBest,\nAdministration");
});
```

Here we add a function for the note object. The command name is either use or read. So if the player types in "use x" or "read x", x being any one of the aliases of the note object, this function is called. If the item is either in the current scene or in the character's inventory, the function is called.

```
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
```

Here we added cupboard's actions.

```
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
```

The actions for clothes object. Here we see the functions called "item.remove()" and "engine.unregister()". They are kind of self explanatory. When you call engine.unregister, there is no way to add that object to the game, unless you call engine.register; whereas when you call item.remove(), it only removes it from its owner.

```
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
```

The actions for the door object. We also make use of  the variable "additionalDescription" here.

```
engine.setAction2(openDoorFunc, "(unlock|open) $1 with $2", door, pencil);
engine.setAction2(openDoorFunc, "(use) $1 with $2", pencil, door);
```

This is the second set action function. it's more complicated; it lets you use multiple objects and label them with $1,2,3, etc. The parser will replace the dollars with all of the items' aliases with respect to the argument array. For example, "(unlock|open) $1 with $2", door, pencil means (unlock or open) + any one of the aliases of "door" + with + any one of the aliases of "pencil". You can use as many number of objects as you want. Below we will define openDoorFunc.

```
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
		
		engine.setState(sceneWin, character, engine);
	}
};
```

Here we use engine.setState(nextScene, character = null, interactionHandler = null). What it does is it changes the scene to the next scene, the character to the given character, and the interaction handler to the 3rd argument. If character is null, the previous character is kept. If interaction handler is null, it is assigned to the engine.

Now for some detail, every class is derived from ActionHandler class, which is simply a command parser and action caller. The interactionHandler in the engine controls the input output flow; so that whenever a new input comes, the engine runs the parse command of the interactionHandler, and it returns the result. So, the interaction can be handled by scenes, items, dialogue objects (which we will see soon), characters, NPC's, etc.

```
sceneMainRoom.onEnter = function(prevScene:Scene = null) {
	if (telephone.getProp("ringing") == true) {
		telephone.startTimer();
	}
}
sceneMainRoom.onLeave = function(nextScene:Scene = null) {
	telephone.stopTimer();
}
```

Every scene has onEnter and onLeave functions. They are called when a scene is entered and leaved. Here we start or stop the telephone's timer, so that it stops ringing when the player is on another room.

```
engine.setAction1(telephone, "(pick up|answer|use|take|grab)", function() {
	telephone.stopTimer();
	telephone.startChat();
});
```

Here the overridePickup variable comes in handy. Make sure to override all three possible words for default pick up action, "pick up", "take" and "grab".

The startChat method is available in every item, npc or character, and what it does is it assigns the dialogue object of that item to the engine's interactionHandler, so that the dialogue objects controls the IO flow now.

## 6. Adding Dialogues ##

```
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
```

Dialogues consist of states and answers. Answers are what the character respond by choosing an answer, and the states are what the npc or the item, etc. says. the functions defined here are the callback functions, once those states or answers are entered. Answers also have next states, which are given as argument to the constructed. Then you add the answers to the states as children with addAnswer method, and you add the states to the dialogue object with addState method. Then you add the dialogue object to the item with setDialogue method. Items can have 1 dialogue object, so setDialogue replaces the old dialogue, if there's any.

## 7. Running the game ##

```
engine.printLine("Welcome to the demo game. Type \"help\" to display the help text. Type \"describe\" to begin playing by describing your environment.");
engine.printLine("--------------------------------------------------");
engine.setState(sceneMainRoom, character, sceneMainRoom);
```

By now you should have a functioning game! Hope you had fun. For any questions, you can email me or ask from here.

Cheers,
Cem