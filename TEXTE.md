# Fingerfist — Text-Überarbeitung

So funktioniert's:
- Jeder Eintrag hat eine **ID** (nicht ändern), den **Fundort**, den **aktuellen** Text und ein **`NEU:`**-Feld.
- Das `NEU:`-Feld ist mit dem aktuellen Text **vorbefüllt**. Ändere einfach die Zeile hinter `NEU:` — was korrekt ist, lässt du stehen.
- 🔢 = enthält **Platzhalter** (`%d` = Zahl, `%s` = Text, `%%` = Prozentzeichen). Diese MÜSSEN erhalten bleiben, sonst crasht/verrutscht die Anzeige. Reihenfolge der Platzhalter beibehalten.
- `\n` bedeutet **Zeilenumbruch** im Spiel — bitte als `\n` stehen lassen.
- Sprache: Englisch bleibt Englisch, nur inhaltlich falsche Texte fixen (du entscheidest pro Zeile).

Wenn du fertig bist: sag Bescheid, dann spiele ich alle `NEU:`-Werte zurück ins Spiel.

---

## Main Menu

- `mm_play` — MainMenu.tscn / PlayButton
  Aktuell: `PLAY`
  NEU: PLAY
- `mm_newgame` — MainMenu.tscn / NewGameButton
  Aktuell: `NEW GAME`
  NEU: NEW GAME
- `mm_shop` — MainMenu.tscn / ShopButton
  Aktuell: `SHOP`
  NEU: SHOP
- `mm_settings` — MainMenu.tscn / SettingsButton
  Aktuell: `SETTINGS`
  NEU: SETTINGS
- `mm_quit` — MainMenu.tscn / QuitButton
  Aktuell: `QUIT`
  NEU: QUIT
- `mm_title` — MainMenu.gd (Titel)
  Aktuell: `FINGERFIST`
  NEU: FINGERFIST 
- `mm_dlg_title` — MainMenu.gd (New-Game-Dialog Titel)
  Aktuell: `NEW GAME`
  NEU: NEW GAME
- `mm_dlg_msg` — MainMenu.gd (New-Game-Dialog Text)  🔢 `\n`
  Aktuell: `Start new game?\nYour Progress will be lost.`
  NEU: Start new game?\nYour Progress will be lost.
- `mm_dlg_yes` — MainMenu.gd (Dialog Bestätigen)
  Aktuell: `YES, RESET`
  NEU: YES, RESET
- `mm_dlg_no` — MainMenu.gd (Dialog Abbrechen)
  Aktuell: `CANCEL`
  NEU: CANCEL

## Level Select

- `ls_title` — LevelSelect.tscn + .gd (Überschrift)
  Aktuell: `SELECT LEVEL`
  NEU: SELECT LEVEL
- `ls_back` — LevelSelect.tscn (Zurück)
  Aktuell: `Back`
  NEU: Back
- `ls_lvlname_1` — LevelSelect.gd (Level-Name 1)
  Aktuell: `Fire and Shadows`
  NEU: Fire and Shadows
- `ls_lvlname_2` — LevelSelect.gd (Level-Name 2)
  Aktuell: `Endless Cave`
  NEU: Endless Cave
- `ls_lvlname_3` — LevelSelect.gd (Level-Name 3)
  Aktuell: `Hope`
  NEU: Hope
- `ls_lvlname_4` — LevelSelect.gd (Level-Name 4)
  Aktuell: `Holding On`
  NEU: Holding On
- `ls_lvlname_5` — LevelSelect.gd (Level-Name 5)
  Aktuell: `Willpower`
  NEU: Willpower
- `ls_lvlname_6` — LevelSelect.gd (Level-Name 6)
  Aktuell: `Into the Light`
  NEU: Into the Light
- `ls_lvlname_7` — LevelSelect.gd (Level-Name 7)
  Aktuell: `Final Stand under the Sun`
  NEU: Final Stand under the Sun
- `ls_stat_total` — LevelSelect.gd  🔢 `%d` `\n`
  Aktuell: `Total Score:\n   %d`
  NEU: Total Score:\n   %d
- `ls_stat_coins` — LevelSelect.gd  🔢 `%d` `\n`
  Aktuell: `Coins:\n   %d`
  NEU: Coins:\n   %d
- `ls_stat_unlocked` — LevelSelect.gd  🔢 `%d` `\n`
  Aktuell: `Levels Unlocked:\n   %d / 7`
  NEU: Levels Unlocked:\n   %d / 7
- `ls_btn_unlocked` — LevelSelect.gd (Level-Button freigeschaltet)  🔢 `%d` `%s` `\n`
  Aktuell: `Level %d\n%s`
  NEU: Level %d\n%s
- `ls_btn_locked` — LevelSelect.gd (Level-Button gesperrt)  🔢 `%d` `\n`
  Aktuell: `Level %d\nLOCKED`
  NEU: Level %d\nLOCKED
- `ls_items_header` — LevelSelect.gd
  Aktuell: `YOUR ITEMS (tap to activate for this run)`
  NEU: YOUR ITEMS (tap to activate for this run)
- `ls_start` — LevelSelect.gd (Start-Button)
  Aktuell: `START LEVEL`
  NEU: START LEVEL
- `ls_detail_back` — LevelSelect.gd (Detail Zurück)
  Aktuell: `BACK`
  NEU: BACK
- `ls_detail_title` — LevelSelect.gd  🔢 `%d` `%s`
  Aktuell: `Level %d - %s`
  NEU: Level %d - %s
- `ls_endless` — LevelSelect.gd
  Aktuell: `Endless Mode - No Wall`
  NEU: Endless Mode - No Wall
- `ls_wallhp` — LevelSelect.gd  🔢 `%d` `%d`
  Aktuell: `Wall HP: %d / %d`
  NEU: Wall HP: %d / %d
- `ls_highscore` — LevelSelect.gd  🔢 `%d`
  Aktuell: `Highscore: %d`
  NEU: Highscore: %d
- `ls_highscore_none` — LevelSelect.gd
  Aktuell: `Highscore: Not Set`
  NEU: Highscore: Not Set
- `ls_combo` — LevelSelect.gd  🔢 `%d`
  Aktuell: `Best Combo: %d`
  NEU: Best Combo: %d
- `ls_combo_none` — LevelSelect.gd
  Aktuell: `Best Combo: Not Set`
  NEU: Best Combo: Not Set
- `ls_noitems` — LevelSelect.gd
  Aktuell: `No items owned — visit the Shop to buy items.`
  NEU: No items owned — visit the Shop to buy items.
- `ls_item_active` — LevelSelect.gd  🔢 `%s`
  Aktuell: `%s - ACTIVE`
  NEU: %s - ACTIVE
- `ls_item_inactive` — LevelSelect.gd  🔢 `%s`
  Aktuell: `%s - inactive`
  NEU: %s - inactive

## HUD (während des Spiels)

- `hud_score` — HUD.gd  🔢 `%d`
  Aktuell: `Score: %d`
  NEU: Score: %d
- `hud_coins` — HUD.gd  🔢 `%d`
  Aktuell: `Coins: %d`
  NEU: Coins: %d
- `hud_combo` — HUD.gd  🔢 `%d`
  Aktuell: `COMBO x%d`
  NEU: COMBO x%d

## EndScreen (Rundenende)

- `end_title_highscore` — EndScreen.gd (Titel bei neuem Highscore)
  Aktuell: `NEW HIGHSCORE!`
  NEU: NEW HIGHSCORE!
- `end_title_victory` — EndScreen.gd (Titel bei Sieg / Wand zerstört)
  Aktuell: `Wall shatterd!`
  NEU: Wall shatterd!
- `end_title_died` — EndScreen.gd (Titel wenn Spieler STIRBT)
  Aktuell: `GAME OVER`
  NEU: GAME OVER
- `end_title_survived` — EndScreen.gd (Titel wenn Runde abläuft & Wand noch steht)
  Aktuell: `The Wall Still Stands`
  NEU: The Wall Still Stands
- `end_round_score` — EndScreen.gd  🔢 `%d`
  Aktuell: `Round Score: %d`
  NEU: Round Score: %d
- `end_total_score` — EndScreen.gd  🔢 `%d`
  Aktuell: `Total Score: %d`
  NEU: Total Score: %d
- `end_coins` — EndScreen.gd  🔢 `%d`
  Aktuell: `Coins Earned: %d`
  NEU: Coins Earned: %d
- `end_combo` — EndScreen.gd  🔢 `%d`
  Aktuell: `Highest Combo: x%d`
  NEU: Highest Combo: x%d
- `end_kills` — EndScreen.gd  🔢 `%d`
  Aktuell: `Enemies Killed: %d`
  NEU: Enemies Killed: %d
- `end_time` — EndScreen.gd  🔢 `%02d` `%02d`
  Aktuell: `Time: %02d:%02d`
  NEU: Time: %02d:%02d
- `end_btn_shop` — EndScreen.tscn (Button)
  Aktuell: `Shop`
  NEU: Shop
- `end_btn_retry` — EndScreen.tscn (Button)
  Aktuell: `Retry`
  NEU: Retry
- `end_btn_menu` — EndScreen.tscn (Button)
  Aktuell: `Menu`
  NEU: Menu

## Pause-Menü (in allen Levels gleich)

- `pause_title` — game.tscn + Level1-7.tscn
  Aktuell: `PAUSED`
  NEU: PAUSED
- `pause_continue` — game.tscn + Level1-7.tscn
  Aktuell: `Continue`
  NEU: Continue
- `pause_save` — game.tscn + Level1-7.tscn
  Aktuell: `Save`
  NEU: Save
- `pause_restart` — game.tscn + Level1-7.tscn
  Aktuell: `Restart`
  NEU: Restart
- `pause_menu` — game.tscn + Level1-7.tscn
  Aktuell: `Main Menu`
  NEU: Main Menu

## Shop

- `shop_title` — shop.tscn + .gd (Überschrift)
  Aktuell: `ITEM SHOP`
  NEU: ITEM SHOP
- `shop_back` — shop.gd / shop.tscn
  Aktuell: `BACK`
  NEU: BACK
- `shop_cat_all` — shop.gd (Filter-Kategorie)
  Aktuell: `All`
  NEU: All
- `shop_cat_combat` — shop.gd
  Aktuell: `Combat`
  NEU: Combat
- `shop_cat_defense` — shop.gd
  Aktuell: `Defense`
  NEU: Defense
- `shop_cat_economy` — shop.gd
  Aktuell: `Economy`
  NEU: Economy
- `shop_cat_utility` — shop.gd
  Aktuell: `Utility`
  NEU: Utility
- `shop_cat_ultimate` — shop.gd
  Aktuell: `Ultimate`
  NEU: Ultimate
- `shop_cost` — shop.gd  🔢 `%d`
  Aktuell: `Cost: %d Coins`
  NEU: Cost: %d Coins
- `shop_status_owned` — shop.gd
  Aktuell: `Status: OWNED`
  NEU: Status: OWNED
- `shop_deactivate` — shop.gd
  Aktuell: `DEACTIVATE`
  NEU: DEACTIVATE
- `shop_activate` — shop.gd
  Aktuell: `ACTIVATE`
  NEU: ACTIVATE
- `shop_status_notowned` — shop.gd
  Aktuell: `Status: Not Owned`
  NEU: Status: Not Owned
- `shop_buy` — shop.gd
  Aktuell: `BUY NOW`
  NEU: BUY NOW
- `shop_status_cantafford` — shop.gd
  Aktuell: `Status: Cannot Afford`
  NEU: Status: Cannot Afford
- `shop_confirm_title` — shop.gd
  Aktuell: `CONFIRM PURCHASE`
  NEU: CONFIRM PURCHASE
- `shop_confirm_yes` — shop.gd
  Aktuell: `YES, BUY IT`
  NEU: YES, BUY IT
- `shop_confirm_no` — shop.gd
  Aktuell: `CANCEL`
  NEU: CANCEL
- `shop_confirm_msg` — shop.gd  🔢 `%s` `%d` `%d` `\n`
  Aktuell: `Purchase '%s' for %d coins?\n\nYou currently have %d coins.`
  NEU: Purchase '%s' for %d coins?\n\nYou currently have %d coins.

## Items (Name + Beschreibung)

- `item_greed_name` — SaveSystem.gd
  Aktuell: `Greed Magnet`
  NEU: Greed Magnet
- `item_greed_desc` — SaveSystem.gd
  Aktuell: `Zieht Coins an (200px Radius)`
  NEU: Zieht Coins an (200px Radius)
- `item_iron_name` — SaveSystem.gd
  Aktuell: `Iron Knuckles`
  NEU: Iron Knuckles
- `item_iron_desc` — SaveSystem.gd
  Aktuell: `Knockback-Effekt auf Gegner`
  NEU: Knockback-Effekt auf Gegner
- `item_shockwave_name` — SaveSystem.gd
  Aktuell: `Shockwave Fist`
  NEU: Shockwave Fist
- `item_shockwave_desc` — SaveSystem.gd
  Aktuell: `Verdoppelt Attack-Radius`
  NEU: Verdoppelt Attack-Radius
- `item_time_name` — SaveSystem.gd
  Aktuell: `Time Crystal`
  NEU: Time Crystal
- `item_time_desc` — SaveSystem.gd
  Aktuell: `Slow-Motion bei 10er Combo`
  NEU: Slow-Motion bei 10er Combo
- `item_golem_bless_name` — SaveSystem.gd
  Aktuell: `Golem's Blessing`
  NEU: Golem's Blessing
- `item_golem_bless_desc` — SaveSystem.gd
  Aktuell: `Wall regeneriert 1 HP/s (max 10% Total HP)`
  NEU: Wall regeneriert 1 HP/s (max 10% Total HP)
- `item_fireshield_name` — SaveSystem.gd
  Aktuell: `Fire Shield`
  NEU: Fire Shield
- `item_fireshield_desc` — SaveSystem.gd
  Aktuell: `Negiert 1 Projektil pro Runde`
  NEU: Negiert 1 Projektil pro Runde
- `item_golemskin_name` — SaveSystem.gd
  Aktuell: `Golem Skin`
  NEU: Golem Skin
- `item_golemskin_desc` — SaveSystem.gd
  Aktuell: `+3 Extra Leben (HP 5->8)`
  NEU: +3 Extra Leben (HP 5->8)
- `item_thunder_name` — SaveSystem.gd
  Aktuell: `Thunder Charge`
  NEU: Thunder Charge
- `item_thunder_desc` — SaveSystem.gd
  Aktuell: `Chain Lightning bei 20er Combo (Blitz alle 10 Treffer)`
  NEU: Chain Lightning bei 20er Combo (Blitz alle 10 Treffer)
- `item_wrath_name` — SaveSystem.gd
  Aktuell: `Call of Wrath`
  NEU: Call of Wrath
- `item_wrath_desc` — SaveSystem.gd
  Aktuell: `Meteoriten + x2 Score bei 30+ Combo`
  NEU: Meteoriten + x2 Score bei 30+ Combo

## Settings

- `set_title` — Settings.tscn + .gd
  Aktuell: `SETTINGS`
  NEU: SETTINGS
- `set_back` — Settings.tscn
  Aktuell: `BACK`
  NEU: BACK
- `set_sfx` — Settings.gd  🔢 `%d` `%%`
  Aktuell: `SFX Volume: %d%%`
  NEU: SFX Volume: %d%%
- `set_music` — Settings.gd  🔢 `%d` `%%`
  Aktuell: `Music Volume: %d%%`
  NEU: Music Volume: %d%%
- `set_fullscreen` — Settings.gd
  Aktuell: `Fullscreen:`
  NEU: Fullscreen:
- `set_reset` — Settings.gd
  Aktuell: `RESET TO DEFAULTS`
  NEU: RESET TO DEFAULTS

## Credits

- `cr_title` — credits.gd
  Aktuell: `FINGERFIST`
  NEU: FINGERFIST
- `cr_line_by` — credits.gd (Zeile 1)
  Aktuell: `— A Game By —`
  NEU: — A Game By —
- `cr_line_seb` — credits.gd
  Aktuell: `Sebastian`
  NEU: Sebastian
- `cr_line_claude` — credits.gd
  Aktuell: `Claude`
  NEU: Claude
- `cr_line_omnia` — credits.gd
  Aktuell: `Omnia Vortex`
  NEU: Omnia Vortex
- `cr_line_engine` — credits.gd
  Aktuell: `Made with Godot 4.4`
  NEU: Made with Godot 4.4
- `cr_back` — credits.gd
  Aktuell: `Back`
  NEU: Back

## Highscore

- `hs_title` — Highscore.gd
  Aktuell: `HIGHSCORES`
  NEU: HIGHSCORES
- `hs_row` — Highscore.gd  🔢 `%d` `%s`
  Aktuell: `Level %d  %s`
  NEU: Level %d  %s
- `hs_totals` — Highscore.gd  🔢 `%d` `%d`
  Aktuell: `Total Score: %d        Coins: %d`
  NEU: Total Score: %d        Coins: %d
- `hs_back` — Highscore.gd
  Aktuell: `Back`
  NEU: Back

## Save-Slots

- `ss_title` — SaveSlotSelect.gd
  Aktuell: `Select Save Slot`
  NEU: Select Save Slot
- `ss_slot` — SaveSlotSelect.gd  🔢 `%d`
  Aktuell: `SLOT %d`
  NEU: SLOT %d
- `ss_info` — SaveSlotSelect.gd  🔢 `%d` `%d` `%d` `%s` `\n` (enthält `|`-Zeichen als Trenner)
  Aktuell: `Level %d | Score: %d | Coins: %d\nLast Save: %s`
  NEU: Level %d | Score: %d | Coins: %d\nLast Save: %s
- `ss_load` — SaveSlotSelect.gd
  Aktuell: `Load`
  NEU: Load
- `ss_delete` — SaveSlotSelect.gd
  Aktuell: `Delete`
  NEU: Delete
- `ss_empty` — SaveSlotSelect.gd
  Aktuell: `Empty Slot`
  NEU: Empty Slot
- `ss_new` — SaveSlotSelect.gd
  Aktuell: `New Game`
  NEU: New Game
- `ss_back` — SaveSlotSelect.gd
  Aktuell: `Back`
  NEU: Back
- `save_indicator` — SaveIndicator.gd (kurze Einblendung beim Speichern)
  Aktuell: `Saved`
  NEU: Saved
