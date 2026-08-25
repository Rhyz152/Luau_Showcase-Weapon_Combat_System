# **Note - Not all scripts are shown in this reprository (for security reasons)**
# *Info*
This repository is a showcase of a weapon combat system programmed with Luau - by Rhyz152
This combat system is inspired by the combat of Bleach Roblox game, **VV Ultimatum.**
Before reading this documentation, it is highly recommended to read the scripts as it is explained better if you have but you don't really need to understand it, since I explain it here.
This project using the following Packages: React, ReactRoblox
**If you're wondering what a 'Zanpakuto' is,** its the word for weapon (basically) in Bleach (manga/anime).\
***VIDEO LINK: https://youtu.be/ay8yiLCVK8U***

# *Combat System*
In this project, I use a **table of data (name, damage, animation id, etc)** to efficiently make it so that we don't have to manually change variables, and other things that may need changing, to just get the same keyword (like CombatData.Damage, makes sense if you read the scripts).
To make this system responsive to the user and satisfying as possible without going overboard, I made a **client-based combat system, server for validating everything.**
The client presses mouse button 1 which invokes a remote function to the server to retrieve the player's current combo, and if they are able to actually ues combat now (like if they're Unarmed then it nothing will happen, cooldown, etc.)
The server reads tables containing the last time the player request to melee & their current number in the index, this gets resetted if its been 1.75s after their last request.
The server, if everything checks, returns a string like "Swing1".
The client uses this string to find the data table in Combat Data (like CombatData.Swing2 or CombatData.FinisherSwing).
The client plays the animation using a custom animation handler as we pass in the animation id from the combat data of the current combo swing.
When a certain keyframe marker is reached, we create a client hitbox using a hitbox creation handler and we set custom properties depending whether it is the finishing swing or not.
Additionally, we play swoosh sfx and vfx.
To query, the client invokes a remote function to the server.
The server gets the current player's combo from the table and gets the combat data swing's damage and knockback multiplier.
Using workspace:GetPartsBoundInBox(...) to iterate through everything inside of the hitbox.
The server checks whether it is a valid character by checking if the part doesn't have a model as its parent, if its already queried (AlreadyHit[OtherCharacter] - boolean) or if its the player's own character.
After, if it passes through, it gets the Humanoid and root part.
Using the combo key's damage, we make the humanoid take damage and we use a knocback utility, if its the final swing, to knocback the character inside of the hitbox in the direction the player (attacker) is facing.
The server returns the hit character's root part to the client.
Using the root part of the other character, sfx & vfx plays to show that they've been damaged.
Also, it plays a hit animation.

# *Toggle System*
In this project, instead of using normal tools, I implemented a toggle system of **responsively cloning a pre-made model into the player's character (their right arm in this project) and used Cframe values to correctly set the Cframe of the new model.**
To begin, the client sends an input, via an Input detection utility that tracks input and returns callbacks (functions written inside of any script so in this example the client presses 'X' and it runs the function passed in (as an argument)).
The server gets some stored assets from ServerStorage.
The best and most efficient way of holstering weapons is using accessories, I can set them up for your game if needed.
To make sure that we can get a quick cleanup and store the player's equipped weapons and holsters, we use tables.
The function 'CreateWeapon(...)' gets the stored holsters in the table and destroys them (if they're an accessory).
Then, it clones the weapon asset and uses a stored Cframe value inside of the asset to set the Cframe of the new model (parented to the player's right arm).
By this, we are able to efficiently rotate and position the weapon where the blade is facing in front of the player and is at the angle it is.
Additionally, we play animations, sfx, and vfx on the client for a smooth responsive system, instead of heavily loading the server and waiting for responses.
The function 'DestroyWaepon(...)' does the opposite, gets the player's weapon and destroys it.
It then clones the accessory and uses the function 'AddAccessory(...)' found in the Humanoid class.

# *Player State utility*
To make sure that multiple scripts, that require the player's current state', I programmed a **player state controller that initializes states, enables states (that disable all other states), and gets state values.**
In case of adding new states (or removing) and making sure every player has the same states (as in they all have an Unarmed state for example), I made a dict of state names and their starting values (bools).
When the 'InitPlayerStates(...)' function is called, it copies the States table to another table of the Player.
This makes sure we can do things like PlayerStates[Player]["Unarmed"] (finds the "Unarmed" key in the player's states).
The function 'EnabledPlayerState(...)' checks if the sent if state that is meant to be enabled is an actual state (there are 2 local functions made for this purpose to avoid re-writing).
It iterates through every state in the PlayerStates[Player] and skips the passed in state name, disabling all others.
The function 'GetPlayerState(...)' checks if the sent state is a valid state and returns the value of it, if the state is valid.
