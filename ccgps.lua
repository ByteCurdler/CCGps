term.clear()

marker = function(char, vec, fgcolor, snap)
    if snap then
        normlen = math.max(math.abs(vec.x),
                           math.abs(vec.y))
    else
        normlen = math.max(math.max(math.abs(vec.x),
                                    math.abs(vec.y)), MAPRADIUS)
    end
    normvec = vec / vec2(normlen/MAPRADIUS,
                         normlen/MAPRADIUS)
    term.setCursorPos(round(MAPMARGIN+MAPRADIUS+normvec.x),
                      round(MAPTOP+MAPRADIUS+normvec.y))
    term.setTextColor(fgcolor)
    term.write(char)
    term.setTextColor("white")
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

require("vector2")

trailpos = nil
semitrailpos = nil

MAPRADIUS = 8

MAPMARGIN = 6

MAPTOP = 3

SENSITIVITY = 1.5

lastTime = os.clock()

while true do
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

        if arg[3] ~= nil then
            -- Make box
            term.setCursorPos(MAPMARGIN,MAPTOP)
            term.write(string.rep("+", MAPRADIUS) .. "N" .. string.rep("+", MAPRADIUS))
            term.setCursorPos(MAPMARGIN,MAPTOP+(MAPRADIUS*2))
            term.write(string.rep("+", MAPRADIUS) .. "S" .. string.rep("+", MAPRADIUS))
            for i = MAPTOP+1, MAPTOP+(MAPRADIUS*2)-1 do
                term.setCursorPos(MAPMARGIN,i)
                if i == MAPTOP+MAPRADIUS then
                    term.write("W" .. string.rep("-", MAPRADIUS-1) .. "+" .. string.rep("-", MAPRADIUS-1) .. "E")
                else
                    term.write("+" .. string.rep(" ", MAPRADIUS-1) .. "|" .. string.rep(" ", MAPRADIUS-1) .. "+")
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
            dx = arg[1] - x + 0.5
            dz = arg[3] - z + 0.5
            dvec = vec2(dx, dz)
            marker("=", vec2(0, arg[2]-y), "orange")
            marker("@", dvec, "green")
            if trailpos ~= nil then
                marker("^", semitrailpos - trailpos, "red", true)
            end
            --if trail[1]
            term.setBackgroundColor("black")
        end
    end
    while (os.clock() - lastTime < 0.1) do end
    lastTime = os.clock()
end
