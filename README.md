# OSRS DPS Calculator
**Bronson Graansma**

## Introduction
The OSRS DPS Calculator is an iOS app developed in Swift 4, which will calculate the damage per second of an [*OldSchool RuneScape*](http://oldschool.runescape.com) character in game. The app uses the following things to determine DPS:

* combat style
* stats
* settings
	* opponent
	* slayer task
* temporary stat altering consumables
* equipment
* prayers
* spells

All calculations are performed according to the specifications found on [this thread](http://services.runescape.com/m=forum/forums.ws?317,318,712,65587452). All art used within the application belongs to [Jagex Ltd.](https://www.jagex.com/) (the owners and creators or *OldSchool RuneScape*), and were downloaded from [the wiki](http://oldschoolrunescape.wikia.com/wiki/Old_School_RuneScape_Wiki).

## Completion
The app is fully functional. The only things missing are more equipment, and more opponents. These additions would require absolutely no code changes. These additions only require some data to be appended to `opponents.json` and `equipment.json` in the `Data` folder. Currently a small subset of equipment is available, as there are [at least 2,420](http://oldschoolrunescape.wikia.com/wiki/Category:Equipable_items) total. Currently a small subset of opponents are avalable, as there are [at least 137](http://oldschoolrunescape.wikia.com/wiki/Category:Monsters) total. In order to add more equipment and opponents, it is only a matter of simple data entry.

## Potential Enhancements
* The addition of more equipment and opponents.
* Data files to be hosted online, to reduce app size, and allow for the addition of new prayers, items, equipment, spells, opponents, etc, without recompiling the app.
* Support for different sized devices.

## Xcode Simulator
The app was tested on iPhone 8 Plus, and looks very good on it. There is no guaruntee that the app will look as good or be as usable as it is on the iPhone 8 Plus. It is recommended that when this app is run in a simulator, that the hardware keyboard be disconnected. To do this, simply make sure `Hardware > Keyboard > Connect Hardware Keyboard` is unchecked in the simulator. The reason for this is, that this app makes use of the numberpad keyboard for some user input. If non numeric characters are entered (through the hardware keyboard) while the numberpad keyboard is presented, an exception is thrown and the app crashes. The crash doesn't occur from this app's code base, as nonnumeric characters are removed from those specific user inputs. The crash occurs from the numberpad keyboard interaction.

## How To Use
DPS, max hit, and hit potential (chance to land a hit), are displayed at the top of the screen on each tab. Navigating to other tabs allow you to change parameters specific to each tab.

### ![Combat style tab](http://c-7npsfqifvt34x24wjhofuufx2ex78jljbx2eopdppljfx2eofu.g00.wikia.com/g00/3_c-7pmetdippmsvoftdbqf.x78jljb.dpn_/c-7NPSFQIFVT34x24iuuqtx3ax2fx2fwjhofuuf.x78jljb.opdppljf.ofux2f3118tdbqfx2fjnbhftx2f2x2f29x2fDpncbu_Pqujpot.qohx2fsfwjtjpox2fmbuftux3fdcx3d31241428232458x26j21d.nbslx3djnbhf_$/$/$/$/$/$/$/$) Combat Style
The combat style can be selected from the combat style tab. Your selected combat style is important, as some styles will have invisible boosts to your accuracy or damage. In order to calculate your DPS for casting a spell, the spell combat style must be selected here. Available combat styles for selection depend on the equipped weapon. To select a combat style, simply press the desired style, which will indicate your selection by taking on a red background.

### ![Stats tab](http://c-7npsfqifvt34x24wjhofuufx2ex78jljbx2eopdppljfx2eofu.g00.wikia.com/g00/3_c-7pmetdippmsvoftdbqf.x78jljb.dpn_/c-7NPSFQIFVT34x24iuuqtx3ax2fx2fwjhofuuf.x78jljb.opdppljf.ofux2f3118tdbqfx2fjnbhftx2fbx2fbbx2fTubut.qohx2fsfwjtjpox2fmbuftux3fdcx3d31241428233144x26j21d.nbslx3djnbhf_$/$/$/$/$/$/$/$) Stats
Character stats can be set in the stats tab. Your character's stats are important as they very heavily influence your accuracy and damage potential. Here you will be able to see the effects of any temporary stat altering consumables being used. To set the level of one of the stats, simply press on the desired stat. This will present a text input prompting for a numeric input (number pad keyboard). Type the number, and press the "Done" button. Any entry below 1 will become 1, and any entry above 99 will become 99. To quickly set all the stats to match those of an existing *OldSchool RuneScape* character, press on the textbox labeled "rsn" (*RuneScape* name). Type in the character's display name, followed by enter or return. This will populate each stat automatically. If the display name was not found on the [*OldSchool RuneScape* HiScores](http://services.runescape.com/m=hiscore_oldschool/overall.ws), no changes will take place. Stats will also lock some selections in various other tabs. Locked content will appear to be greyed out or dimmer than their available counterparts. These limitations include:

* opponents which you do not meet the minimum slayer requirement to attack.
* equipment which you do not meet the minimum stat requirement(s) to equip.
* prayers which you do not meet the minimum prayer requirement to activate.
* spells which you do not meet the minimum magic requirement to cast.

Names lookup reccomendations for app testing:

* **Zulu** (maxed stats to unlock all content within the app)
* **Et** (short name for quick tests)
* **Mini Figure** (my character)
* Feel free to try anything to see if a character exists.

### ![Settings tab](http://c-7npsfqifvt34x24wjhofuufx2ex78jljbx2eopdppljfx2eofu.g00.wikia.com/g00/3_c-7pmetdippmsvoftdbqf.x78jljb.dpn_/c-7NPSFQIFVT34x24iuuqtx3ax2fx2fwjhofuuf.x78jljb.opdppljf.ofux2f3118tdbqfx2fjnbhftx2f9x2f9cx2fPqujpot.qohx2fsfwjtjpox2fmbuftux3fdcx3d31281335133913x26j21d.nbslx3djnbhf_$/$/$/$/$/$/$/$) Settings
#### Opponent
The opponent to face in combat can be set in the settings tab. The opponent plays a fair role in calculating DPS. Their defensive stats will work against your accuracy. In rare circumstances, their stats are used to calculate your max hit, when a weapon has special functionality. For example, the [Twisted bow](http://oldschoolrunescape.wikia.com/wiki/Twisted_bow). Whether or not your opponent is undead will determine if you can cast the [Crumble undead](http://oldschoolrunescape.wikia.com/wiki/Crumble_Undead) spell, or use the benefits from the [Salve amulet](http://oldschoolrunescape.wikia.com/wiki/Salve_amulet). To select your opponent, simply press the drop down which is initially labelled "Opponent..." (but will later be labelled the name of the selected opponent). This will present a scrolling picker view. Slide the list of opponents, until the desired opponent is within the selection area. Opponents which you do not meet the minimum slayer requirement to attack will appear greyed out, and no action will take place when selected.

#### Slayer Task
Indicating your slayer task can be done in the settings tab. This will determine whether or not you can cast the [Slayer dart](http://oldschoolrunescape.wikia.com/wiki/Magic_Dart) spell, or use the benefits from the [Slayer helmet](http://oldschoolrunescape.wikia.com/wiki/Slayer_helmet). To indicate that the selected opponent is your slayer task, simply toggle the checkbox labelled "On Slayer Task" by pressing it, such that there is a checkmark in the circle.

### ![Inventory tab](http://c-7npsfqifvt34x24wjhofuufx2ex78jljbx2eopdppljfx2eofu.g00.wikia.com/g00/3_c-7pmetdippmsvoftdbqf.x78jljb.dpn_/c-7NPSFQIFVT34x24iuuqtx3ax2fx2fwjhofuuf.x78jljb.opdppljf.ofux2f3118tdbqfx2fjnbhftx2fex2fecx2fJowfoupsz.qohx2fsfwjtjpox2fmbuftux3fdcx3d31241428233513x26j21d.nbslx3djnbhf_$/$/$/$/$/$/$/$) Temporary Stat Altering Consumables
Temporary stat altering consumables can be selected in the inventory tab. These play an important role in calculating DPS, as they enhance your stats. To select a potion, or any other item, simply press on it. Potions being used will have a cream coloured circle around them. Only one boost per stat is allowed. If an item is selected which boosts a stat which is already being boosted by another item, the old item will be automatically deselected in favour of your most recent selection. A boosted magic level will allow you to cast higher levelled spells. The [locator orb](http://oldschoolrunescape.wikia.com/wiki/Locator_orb) is in the inventory in order to reduce your hitpoints, for circumstances where lowered health will have an effect on DPS calculations, such as [Dharok's armour set](http://oldschoolrunescape.wikia.com/wiki/Dharok_the_Wretched%27s_equipment).

### ![Equipment tab](http://c-7npsfqifvt34x24wjhofuufx2ex78jljbx2eopdppljfx2eofu.g00.wikia.com/g00/3_c-7pmetdippmsvoftdbqf.x78jljb.dpn_/c-7NPSFQIFVT34x24iuuqtx3ax2fx2fwjhofuuf.x78jljb.opdppljf.ofux2f3118tdbqfx2fjnbhftx2f6x2f61x2fXpso_frvjqnfou.qohx2fsfwjtjpox2fmbuftux3fdcx3d31241428233650x26j21d.nbslx3djnbhf_$/$/$/$/$/$/$/$) Equipment
Worn equipment can be set in the equipment tab. Worn equipment has a heavy role in calculating DPS, especially the selected weapon. Also, some spells are only castable when a specific staff is equipped, being: the three [god spells](http://oldschoolrunescape.wikia.com/wiki/God_spells), [Slayer dart](http://oldschoolrunescape.wikia.com/wiki/Magic_Dart), and [Iban blast](http://oldschoolrunescape.wikia.com/wiki/Iban_Blast). To select worn equipment, simply press one of the equipment slots, which will present a scrolling picker view. Slide the list of equipment available for that slot, until the desired one is within the selection area. Equipment which you do not meet the minimum stat requirement(s) to equip will appear greyed out, and no action will take place when selected. Some weapons require the use of both hands. When an two handed weapon is selected, your equipped offhand (if one exists), will be unequipped automatically. Similarly, if you equip an offhand, but you are currently wielding a two handed weapon, the two handed weapon will be unequipped automatically. In the case that a ranged weapon is used, some form of ammunition must be selected (with the exception of the [Crystal bow](http://oldschoolrunescape.wikia.com/wiki/Crystal_bow)), before DPS can be calculated. The total value of selected equipment will appear at the bottom of the tab. This value represents how many in game gold pieces the equipment is worth. Equipment that is tradeable with other players will have their current live price fetched from the [OldSchool RuneScape Grand Exchange Database API](http://runescape.wikia.com/wiki/Application_programming_interface#Graph), since prices are in constant flux due to the law of supply and demand, and market manipulation. Untradeable equipment will simply be worth their shop price, or repair cost, or some other form of gauging the value.

### ![Prayer tab](http://c-7npsfqifvt34x24wjhofuufx2ex78jljbx2eopdppljfx2eofu.g00.wikia.com/g00/3_c-7pmetdippmsvoftdbqf.x78jljb.dpn_/c-7NPSFQIFVT34x24iuuqtx3ax2fx2fwjhofuuf.x78jljb.opdppljf.ofux2f3118tdbqfx2fjnbhftx2f3x2f35x2fQsbzfs-jdpo.qohx2fsfwjtjpox2fmbuftux3fdcx3d31252131316420x26j21d.nbslx3djnbhf_$/$/$/$/$/$/$/$) Prayers
Prayers can be activated in the prayer tab. Prayers apply a multiplier to some DPS calculations. To activate a prayer, simply press on it. Most prayers can be the only prayer active, but the prayers which resemble a brain and a flexing arm, can be used in conjunction with each other. Prayers which you do not meet the minimum prayer requirement for, will appear greyed out, and will not be activated upon selection. Some prayers in game require that your account had at one point finished a quest, or applied a scroll - for the purposes of this app, it is assumed that all prayers are available to the player. When a prayer is selected, any previously activated prayers which aren't compatible will be automatically deselected.

### ![Spell tab](http://c-7npsfqifvt34x24wjhofuufx2ex78jljbx2eopdppljfx2eofu.g00.wikia.com/g00/3_c-7pmetdippmsvoftdbqf.x78jljb.dpn_/c-7NPSFQIFVT34x24iuuqtx3ax2fx2fwjhofuuf.x78jljb.opdppljf.ofux2f3118tdbqfx2fjnbhftx2f1x2f1ex2fTqfmmcppl.qohx2fsfwjtjpox2fmbuftux3fdcx3d31261717193417x26j21d.nbslx3djnbhf_$/$/$/$/$/$/$/$) Spells
Spells can be activated in the spell tab. The selected spell will determine the max hit when using magic combat. Spell selection will only matter if the spell combat style is selected in the combat style tab. To activate a spell, simply press on it. Only one spell can be activated at a time, therefore upon activation of a spell, the previously selected spell will be automatically deselected. Any spells which you do not meet the minimum magic requirement for, or are not equipping an appropriate staff for, or are not fighting an appropriate opponent for, will appear greyed out, and will not be activated upon selection. There is a non combat [spell](http://oldschoolrunescape.wikia.com/wiki/Charge) in the game, which will passively change your max hit while using one of the three [god spells](http://oldschoolrunescape.wikia.com/wiki/God_spells) when an appropriate god cape is equipped - for the purposes of this app, it is assumed that [Charge](http://oldschoolrunescape.wikia.com/wiki/Charge) is cast if your boosted magic level meets the minimum requirement. 

