settings.load("waypoints.dat")

waypoints = settings.get("waypoints")

if waypoints== nil then
    waypoints = {}
end

normvec = function(vec, snap)
    if snap then
        normlen = math.max(math.abs(vec.x),
                           math.abs(vec.y))
    else
        normlen = math.max(math.max(math.abs(vec.x),
                                    math.abs(vec.y)), MAPRADIUS)
    end
    tmp = vec / vec2((normlen/MAPRADIUS),
                     (normlen/MAPRADIUS))
    return vec2(MAPMARGIN+MAPRADIUS+tmp.x, MAPTOP+MAPRADIUS+tmp.y)
end

lerpvec = function(startp, endp, t)
    return startp + (vec2(t,t) * (endp-startp))
end

drawline = function(startp, endp, color)
    diff = startp - endp
    N = math.max(math.abs(diff.x), math.abs(diff.y));
    term.setBackgroundColor(color)
    term.setTextColor("white")
    for step = 0, N do
        if N == 0 then
            t = 0
        else
            t = step/N
        end
        point = lerpvec(startp, endp, t)
        point = vec2(round(point.x), round(point.y))
        term.setCursorPos(point.x, point.y)
        term.write(" ")
        --term.setCursorPos(1, step)
        --term.write(point)
    end
end

lpad = function(str, len, char)
    str = tostring(str)
    if char == nil then
        char = " "
    end
    return str .. string.rep(char, len - #str)
end

round = function(n)
    return math.floor(n+0.5)
end

fround = function(n, digits)
    mult = 10^digits
    return math.floor((n*mult)+0.5)/mult
end

require("vector2")

trailpos = nil
semitrailpos = nil

MAPRADIUS = 7

MAPMARGIN = 7

MAPTOP = 3

CENTER = normvec(vec2(0,0))

--CENTER.x.x.x.x = 0 --crash

SENSITIVITY = 1.5

BASE = vec2(1, 1)

lastTime = os.clock()

if waypoints[arg[1]] ~= nil then
    target = waypoints[arg[1]]
elseif arg[1] == "set" then
    if arg[2] ~= nil then
        if arg[5] ~= nil then
            waypoints[arg[2]] = {arg[3], arg[4], arg[5]}
            print("Set waypoint " .. arg[2] .. " to " .. arg[3] .. "," .. arg[4] .. "," .. arg[5])
        else
            x, y, z = gps.locate()
            if x == nil then
                print("Unknown location")
            else
                waypoints[arg[2]] = {math.floor(x),math.floor(y),math.floor(z)}
                print("Set waypoint " .. arg[2] .. " to " .. math.floor(x) .. "," .. math.floor(y) .. "," .. math.floor(z))
            end
        end
    else
        print("Usage: ccgps set <name> OR ccgps set <name> <x> <y> <z>")
    end
    settings.set("waypoints", waypoints)
    settings.save("waypoints.dat")
    os.exit()
elseif arg[3] ~= nil then
    target = {arg[1], arg[2], arg[3]}
end


term.clear()
while true do
    term.setBackgroundColor("black")
    term.setTextColor("white")
    x, y, z = gps.locate()
    if x == nil then
        term.setCursorPos(1,3)
        term.write("No signal")
    else
        posvec = vec2(x,z)
        term.setCursorPos(1,1)
        term.write("x       y       z       ")
        term.setCursorPos(1,2)
        term.write(lpad(x, 8)
                .. lpad(y, 8)
                .. lpad(z, 8))
        term.setCursorPos(1,3)
        term.clearLine()

        if semitrailpos == nil or (posvec - semitrailpos):length() > SENSITIVITY then
            --term.setCursorPos(1,5)
            --term.clearLine()
            --if semitrailpos ~= nil then print(posvec - semitrailpos) end
            trailpos = semitrailpos
            semitrailpos = posvec
        end

        if target ~= nil then
            -- Make box
            term.setBackgroundColor("gray")
            term.setTextColor("lightGray")
            for i = MAPTOP, MAPTOP+(MAPRADIUS*2) do
                term.setCursorPos(MAPMARGIN,i)
                if i == MAPTOP or i == MAPTOP+(MAPRADIUS*2) then
                    term.write(string.rep("#", MAPRADIUS*2+1))
                else
                    term.write("#" .. string.rep(" ", MAPRADIUS*2-1) .. "#")
                end
            end
            -- Draw target
            --[[normlen = math.max(math.abs(dvec.x),
                               math.abs(dvec.y))
            normvec = dvec / vec2(normlen/3,
                                  normlen/3)
            term.setCursorPos(1, 14)
            print(normvec)
            term.setCursorPos(round(4+normvec.x),
                              round(9+normvec.y))
            term.write("@")]]
            dx = target[1] - x + 0.5
            dz = target[3] - z + 0.5
            dvec = vec2(dx, dz)
            if trailpos ~= nil then
                movingvec = semitrailpos - trailpos
                newvec = dvec:rotate(movingvec:angle_atan(BASE)+180)
                point_at = normvec(newvec, true)
                drawline(CENTER, normvec(newvec:normalize()*vec2(-0.5*MAPRADIUS,-0.5*MAPRADIUS)), "white")
                drawline(CENTER, normvec(newvec, true), "red")
                --drawline(CENTER, normvec(dvec), "red")
            end
            term.setBackgroundColor("black")
            term.setTextColor("white")
            term.setCursorPos(MAPMARGIN, MAPTOP+(MAPRADIUS*2)+1)
            term.clearLine()
            term.write("Distance: " .. tostring(fround(dvec:length(), 2)).."m")
            --if trail[1]
            term.setBackgroundColor("black")
        end
    end
    while (os.clock() - lastTime < 0.1) do end
    lastTime = os.clock()
end
