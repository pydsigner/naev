--[[
-- This is the first "prelude" mission leading to the FLF campaign.
--]]

-- localization stuff, translators would work here
lang = naev.lang()
if lang == "es" then
else -- default english
   title = {}
   text = {}
   misn_desc = {}
   
    title[1] = "Gregar joins the party"
    text[1] = [[A haggard-looking man emerges from the airlock. He says, "Thank goodness you're here. My name is Gregar, I'm with the Frontier Liberation Front. I mean you no harm." He licks his lips in hesitation before continuing. "I have come under attack from a Dvaered patrol. I wasn't violating any laws, and we're not even in Dvaered territory! Anyway, my ship is unable to fly."
    You help Gregar to your cockpit and install him in a vacant seat. He is obviously very tired, but he forces himself to speak. "Listen, I was on my way back from a mission when those Dvaered bastards jumped me. I know this is a lot to ask, but I have little choice seeing how my ship is a lost cause. Can you take me the rest of the way? It's not far. We have a secret base in the %s system. Fly there and contact my comrades. They will take you the rest of the way."
    With that, Gregar nods off, leaving you to decide what to do next. Gregar wants you to find his friends, but harboring a known terrorist, let alone helping him, might not be looked kindly upon by the authorities...]]
   
    misn_title = "Deal with the FLF agent"
    misn_desc[1] = "Take Gregar, the FLF agent to the %s system and make contact with the FLF"
    misn_desc[2] = "Alternatively, turn Gregar in to the nearest Dvaered base"
end

function create()
    misn.accept() -- The player chose to accept this mission by boarding the FLF ship

    destsysname = var.peek("flfbase_sysname")
    destsys = system.get(destsysname)
    
    tk.msg(title[1], string.format(text[1], destsysname))
    
    misn.osdCreate(misn_title, {string.format(misn_desc[1], destsysname), misn_desc[2]})
    
    hook.enter("enter")
    hook.land("land")
end

-- Handle the FLF encounter, Gregar's intervention, and ultimately the search for the base.
-- Q: How far do sensors reach in the nebula?
function enter()
    if system.cur() == destsys then
        dist = 3000 -- distance of the FLF base
        spread = 45 -- max degrees off-course for waypoints

        angle = var.peek("flfbase_angle")
        angle2 = angle + (rnd.rnd() - 0.5) * 2 * spread * 2 * math.pi / 360
        angle3 = angle + (rnd.rnd() - 0.5) * 2 * spread * 2 * math.pi / 360
        
        pilot.toggleSpawn(false)
        pilot.clear()

        faction.get("FLF"):modPlayerRaw(0) -- FLF is neutral to the player for this mission

        -- Pilot is to hyper in somewhere far away from the base.
        
        player.pilot():setPos(vec2.new(dist * math.cos(angle), dist * math.sin(angle)))

        -- Add FLF ships that are to guide the player to the FLF base
        spawnflf()

        player.pilot():setPos(player.pilot():pos - 2 * player.pilot:vel()) -- Compensate for hyperjump

        -- Add FLF base waypoints
        -- Base is at 0,0
        -- Waypoints are 1/3 and 2/3 of the way away, at an angle plus or minus spread degrees from the actual base
        waypunt0 = pilot.add("Waypoint", "dummy", vec2.new(0,0), false) -- The base will be spawned in the origin, but not until the player is close to this waypoint.
        waypunt1 = pilot.add("Waypoint", "dummy", vec2.new(dist / 3 * math.cos(angle2), dist / 3 * math.sin(angle2)), false)
        waypunt2 = pilot.add("Waypoint", "dummy", vec2.new(2 * dist / 3 * math.cos(angle3), 2 * dist / 3 * math.sin(angle3)), false)
        
        waypoint0 = waypunt0[1]
        waypoint1 = waypunt1[1]
        waypoint2 = waypunt2[1]
        
        waypoint1:setInvincible(true)
        waypoint2:setInvincible(true)
        
        
        spawnbase()
        
    end
end

-- There are two cases we need to check here: landing on the FLF base and landing on a Dvaered world.
function land()
    
end

function spawnflf()
    fleetFLF = pilot.add("FLF Vendetta", "dummy", player.pilot():pos(), true)
    flfship = fleetFLF[1]
    --evt.timerStart("toPoint2", 2000)
end

function toPoint2()
    flfship:changeAI(string.format("escort*%u", waypoint2:id()))
    waytimer1 = evt.timerStart("toPoint1", 1000)
end

function toPoint1()
    if vec2.dist(flfship:pos(), waypoint2:pos()) < 300 then
        flfship:changeAI(string.format("escort*%u", waypoint1:id()))
        waytimer0 = evt.timerStart("toPoint0", 1000)
    else
        waytimer1 = evt.timerStart("toPoint1", 1000)
    end
end

function toPoint0()
    if vec2.dist(flfship:pos(), waypoint1:pos()) < 300 then
        flfship:changeAI(string.format("escort*%u", waypoint0:id()))
        -- basetimer = evt.timerStart("spawnbase", 1000)
    else
        waytimer0 = evt.timerStart("toPoint0", 1000)
    end
end

function spawnbase()
    -- TODO: add distance conditional
    diff.apply("FLF_base")
end

function abort()
    misn.finish(false)
end