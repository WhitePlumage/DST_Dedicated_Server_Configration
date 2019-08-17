--There are two functions that will install mods, ServerModSetup and ServerModCollectionSetup. Put the calls to the functions in this file and they will be executed on boot.
 
--ServerModSetup takes a string of a specific mod's Workshop id. It will download and install the mod to your mod directory on boot.
    --The Workshop id can be found at the end of the url to the mod's Workshop page.
    --Example: http://steamcommunity.com/sharedfiles/filedetails/?id=350811795
    --ServerModSetup("350811795")
 
--ServerModCollectionSetup takes a string of a specific mod's Workshop id. It will download all the mods in the collection and install them to the mod directory on boot.
    --The Workshop id can be found at the end of the url to the collection's Workshop page.
    --Example: http://steamcommunity.com/sharedfiles/filedetails/?id=379114180
    --ServerModCollectionSetup("379114180")
     
ServerModSetup("1079538195")    --移动盒子
ServerModSetup("1185229307")    --史诗血量条
ServerModSetup("1301033176")    --中文语言包（服务器版）
ServerModSetup("1530801499")    --Fast Travel (with ui)
ServerModSetup("1458450094")    --Auto Trap Reset
ServerModSetup("1750657150")    --Damage Indicators Together
ServerModSetup("1768821433")    --王国 - 农民小屋
ServerModSetup("375850593")     --Extra Equip Slots
ServerModSetup("375859599")     --Health Info
ServerModSetup("378160973")     --Global Positions
ServerModSetup("661253977")     --Don't Drop Everything
ServerModSetup("934638020")     --智能灭火器
ServerModSetup("362175979")     --Wormhole Marks [DST]
ServerModSetup("569043634")     --Campfire Respawn

--ServerModCollectionSetup("id")
