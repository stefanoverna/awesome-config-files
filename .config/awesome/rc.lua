-- Include awesome libraries, with lots of useful function!
require("awful")
require("beautiful")
require("revelation")
require("naughty")

beautiful.init("/home/steffoz/.config/themes/steffoz/theme")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
"tile",
"tileleft",
"tilebottom",
"tiletop",
"fairh",
"fairv",
"magnifier",
"max",
"fullscreen",
"spiral",
"dwindle",
"floating"
}

-- Table of clients that should be set floating. The index may be either
-- the application class or instance. The instance is useful when running
-- a console app in a terminal like (Music on Console)
--	xterm -name mocp -e mocp
floatapps =
{
	["feh"] = true,
	["Dta Role: Manager"] = true
}

-- Applications to be moved to a pre-defined tag by class or instance.
-- Use the screen and tags indices.
apptags =
{
	["Gran Paradiso"] = { screen = 1, tag = 1 },
	["sonata"] = { screen = 1, tag = 6 },
	["pidgin"] = { screen = 1, tag = 7 },
	["xterm"] = { screen = 1, tag = 2 },
	["epdfview"] = { screen = 1, tag = 4 },
	["thunar"] = { screen = 1, tag = 3 },
	["leafpad"] = { screen = 1, tag= 4 },
	["gedit"] = { screen = 1, tag = 4 },
	["Thunderbird-bin"] = { screen = 1, tag = 5 }
}

-- Define if we want to use titlebar on all applications.
use_titlebar = false
-- }}}

-- {{{ Tags
-- Define tags names
tagnames = {
"www",
"xterm",
"ls",
"pdf",
"mail",
"mpc",
"irc"
}
-- Define tags table.
tags = {}
for s = 1, screen.count() do
	-- Each screen has its own tag table.
	tags[s] = {}
	i=0
	for i,name in ipairs(tagnames) do
		tags[s][i] = tag({ name = name, layout = layouts[1] })
		-- Add tags to screen one by one
		tags[s][i].screen = s
	end
	-- I'm sure you want to see at least one tag.
	tags[s][1].selected = true
end
-- }}}


-- {{{ Wibox
-- Create a textbox widget
clockbox = widget({ type = "textbox", align = "right" })
-- Set the default text in textbox
clockbox.text = "<b><small> " .. AWESOME_RELEASE .. " </small></b>"

-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu.new({ 
	items = { 
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "open terminal", terminal },
		{ "desktop", "thunar /home/steffoz/Desktop/" }
	}
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

 function volume (mode, widget)
     local cardid  = 0
     if mode == "update" then
         local status = io.popen("amixer -c " .. cardid .. " -- sget Master"):read("*all")
         local volume = io.popen("amixer -c " .. cardid .. " -- sget PCM"):read("*all")
        
	 local result = string.match(volume, "(%d?%d?%d)%%")
	 if result == nil then return end

	 volume = tonumber(result)
         status = string.match(status, "%[(o[^%]]*)%]")
 
         local color = "#FF0000"
         if string.find(status, "on", 1, true) then
              color = "#00FF00"
         end
         status = ""
         for i = 1, math.floor(volume / 10) do
             status = status .. "|"
         end
         for i = math.floor(volume / 10) + 1, 10 do
             status = status .. "-"
         end
         status = "-[" ..status .. "]+"
         widget.text = " " .. status .. " "
     elseif mode == "up" then
         awful.util.spawn("amixer -q -c " .. cardid .. " sset PCM 5%+")
         volume("update", widget)
     elseif mode == "down" then
         awful.util.spawn("amixer -q -c " .. cardid .. " sset PCM 5%-")
         volume("update", widget)
     else
         awful.util.spawn("amixer -c " .. cardid .. " sset PCM toggle")
         volume("update", widget)
     end
 end


 tb_volume = widget({ type = "textbox", name = "tb_volume", align = "right" })
 tb_volume:buttons({
 	button({ }, 4, function () volume("up", tb_volume) end),
 	button({ }, 5, function () volume("down", tb_volume) end),
 	button({ }, 1, function () volume("mute", tb_volume) end)
 })
 volume("update", tb_volume)
 awful.hooks.timer.register(5, function()
     volume("update", tb_volume)
 end)


 wifiwidget = widget({type = "textbox", name = "wifiwidget", align = "right" })
 function wifiInfo(adapter)
     spacer = " "
     local f = io.open("/sys/class/net/"..adapter.."/wireless/link")
     local wifiStrength = f:read()
     if wifiStrength == "0" then
         wifiStrength = "Network Down"
     else
         wifiStrength = "Wifi:"..spacer..wifiStrength.."%"
     end
     wifiwidget.text = spacer..wifiStrength..spacer
     f:close()
 end
wifiInfo("wlan0")
 awful.hooks.timer.register(5, function()
     wifiInfo("wlan0")
 end)

 batterywidget = widget({type = "textbox", name = "batterywidget", align = "right" })
function batteryInfo(adapter)
     spacer = " "
     local fcur = io.open("/sys/class/power_supply/"..adapter.."/energy_now")    
     local fcap = io.open("/sys/class/power_supply/"..adapter.."/energy_full")
     local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")

     if fcur == nil then
	 batterywidget.text = spacer.."Bat:"..spacer.."Not present"..spacer
	 return
     end

     local cur = fcur:read()
     local cap = fcap:read()
     local sta = fsta:read()
     local battery = math.floor(cur * 100 / cap)
     if sta:match("Charging") then
         dir = "^"
         battery = "A/C ("..battery.."%)"
     elseif sta:match("Discharging") then
         dir = "v"
         if tonumber(battery) > 25 and tonumber(battery) < 75 then
             battery = battery
         elseif tonumber(battery) < 25 then
             if tonumber(battery) < 10 then
                 naughty.notify({ title      = "Battery Warning"
                                , text       = "Battery low!"..spacer..battery.."%"..spacer.."left!"
                                , timeout    = 5
                                , position   = "top_right"
                                , fg         = beautiful.fg_focus
                                , bg         = beautiful.bg_focus
                                })
             end
             battery = battery
         else
             battery = battery
         end
     else
         dir = "="
         battery = "A/C"
     end
     batterywidget.text = spacer.."Bat:"..spacer..dir..battery..dir..spacer
     fcur:close()
     fcap:close()
     fsta:close()
 end
awful.hooks.timer.register(5, function()
     batteryInfo("BAT0")
 end)


-- Create a systray
mysystray = widget({ type = "systray", align = "right" })

-- Create a wibox for each screen and add it
topstatusbar = {}
bottomstatusbar = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = { 
	button({ }, 1, awful.tag.viewonly),
	button({ modkey }, 1, awful.client.movetotag),
	button({ }, 3, function (tag) tag.selected = not tag.selected end),
	button({ modkey }, 3, awful.client.toggletag),
	button({ }, 4, awful.tag.viewnext),
	button({ }, 5, awful.tag.viewprev) 
}

mytasklist = {}
mytasklist.buttons = { 
	button({ }, 1, function (c) client.focus = c; c:raise() end),
	button({ }, 3, function () awful.menu.clients({ width=250 }) end),
	button({ }, 4, function () awful.client.focus.byidx(1) end),
	button({ }, 5, function () awful.client.focus.byidx(-1) end) 
}

for s = 1, screen.count() do

	-- Create a promptbox for each screen
	mypromptbox[s] = widget({ type = "textbox", align = "left" })

	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	mylayoutbox[s] = widget({ type = "imagebox", align = "right" })
	mylayoutbox[s]:buttons({ 
		button({ }, 1, function () awful.layout.inc(layouts, 1) end),
		button({ }, 3, function () awful.layout.inc(layouts, -1) end),
		button({ }, 4, function () awful.layout.inc(layouts, 1) end),
		button({ }, 5, function () awful.layout.inc(layouts, -1) end) 
	})

	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, mytaglist.buttons)

	-- Create a tasklist widget
	mytasklist[s] = awful.widget.tasklist.new(function(c)
		return awful.widget.tasklist.label.currenttags(c, s)
	end, mytasklist.buttons)

	-- Create the wibox
	topstatusbar[s] = wibox({ position = "top", fg = beautiful.fg_normal, bg = beautiful.bg_normal })
	-- Add widgets to the wibox - order matters
	topstatusbar[s].widgets = { 
		mylauncher,
		mytaglist[s],
		mypromptbox[s],
		tb_volume,
		batterywidget,
		wifiwidget,
		mylayoutbox[s]
	}
	topstatusbar[s].screen = s

	-- Create the wibox
	bottomstatusbar[s] = wibox({ position = "bottom", fg = beautiful.fg_normal, bg = beautiful.bg_normal })
	-- Add widgets to the wibox - order matters
	bottomstatusbar[s].widgets = { 
		mytasklist[s],
		clockbox,
		s == 1 and mysystray or nil 
	}
	bottomstatusbar[s].screen = s

end
-- }}}

-- {{{ Mouse bindings
awesome.buttons({
	button({ }, 3, function () mymainmenu:toggle() end),
	button({ }, 4, awful.tag.viewnext),
	button({ }, 5, awful.tag.viewprev)
})
-- }}}

-- {{{ Key bindings

-- Bind keyboard digits
-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
	keybinding({ modkey }, i,
		function ()
			local screen = mouse.screen
			if tags[screen][i] then
				awful.tag.viewonly(tags[screen][i])
			end
		end):add()
	keybinding({ modkey, "Control" }, i,
		function ()
			local screen = mouse.screen
			if tags[screen][i] then
				tags[screen][i].selected = not tags[screen][i].selected
			end
		end):add()
	keybinding({ modkey, "Shift" }, i,
		function ()
			if client.focus then
				if tags[client.focus.screen][i] then
					awful.client.movetotag(tags[client.focus.screen][i])
				end
			end
		end):add()
	keybinding({ modkey, "Control", "Shift" }, i,
		function ()
			if client.focus then
				if tags[client.focus.screen][i] then
					awful.client.toggletag(tags[client.focus.screen][i])
				end
			end
		end):add()
end


keybinding({ modkey }, "Left", awful.tag.viewprev):add()
keybinding({ modkey }, "Right", awful.tag.viewnext):add()
keybinding({ modkey }, "Escape", awful.tag.history.restore):add()

-- Standard program
keybinding({ modkey }, "\\", function () awful.util.spawn(terminal) end):add()

keybinding({ modkey, "Control" }, "r", function ()
	mypromptbox[mouse.screen].text = awful.util.escape(awful.util.restart())
end):add()
keybinding({ modkey, "Shift" }, "q", awesome.quit):add()

keybinding({ modkey }, "x", function () awful.util.spawn("mpc next") end):add()
keybinding({ modkey }, "z", function () awful.util.spawn("mpc toggle") end):add()
keybinding({ modkey }, "e", function () awful.util.spawn("thunar") end):add()

function changebg() 
	awful.util.spawn("awsetbg -r /home/steffoz/.config/themes/wps/") 
end
awful.hooks.timer.register(120, changebg)
keybinding({ modkey }, "w", changebg):add()


keybinding({ modkey }, "a", revelation.revelation):add()

-- Client manipulation
keybinding({ modkey }, "g", awful.client.maximize):add()
keybinding({ modkey }, "f", function () if client.focus then client.focus.fullscreen = not client.focus.fullscreen end end):add()
keybinding({ modkey }, "q", function () if client.focus then client.focus:kill() end end):add()

-- keybinding({ modkey }, "l", function () awful.client.focus.byidx(1); if client.focus then client.focus:raise() end end):add()
-- keybinding({ modkey }, "k", function () awful.client.focus.byidx(-1);  if client.focus then client.focus:raise() end end):add()
keybinding({ modkey }, "p", function () awful.client.swap.byidx(1) end):add()
keybinding({ modkey }, "o", function () awful.client.swap.byidx(-1) end):add()
keybinding({ modkey }, "m", function () awful.screen.focus(1) end):add()
keybinding({ modkey }, "n", function () awful.screen.focus(-1) end):add()

keybinding({ modkey, "Control" }, "space", awful.client.togglefloating):add()
keybinding({ modkey, "Control" }, "Return", function () if client.focus then client.focus:swap(awful.client.getmaster()) end end):add()
-- keybinding({ modkey }, "o", awful.client.movetoscreen):add()
keybinding({ modkey }, "Tab", awful.client.focus.history.previous):add()
keybinding({ modkey }, "u", awful.client.urgent.jumpto):add()
keybinding({ modkey, "Shift" }, "r", function () if client.focus then client.focus:redraw() end end):add()

-- Layout manipulation
keybinding({ modkey }, "l", function () awful.tag.incmwfact(0.05) end):add()
keybinding({ modkey }, "k", function () awful.tag.incmwfact(-0.05) end):add()

keybinding({ modkey, "Shift" }, "h", function () awful.tag.incnmaster(1) end):add()
keybinding({ modkey, "Shift" }, "l", function () awful.tag.incnmaster(-1) end):add()
keybinding({ modkey, "Control" }, "h", function () awful.tag.incncol(1) end):add()
keybinding({ modkey, "Control" }, "l", function () awful.tag.incncol(-1) end):add()
keybinding({ modkey }, "space", function () awful.layout.inc(layouts, 1) end):add()
keybinding({ modkey, "Shift" }, "space", function () awful.layout.inc(layouts, -1) end):add()

-- Prompt
keybinding({ modkey }, "r", function ()
	awful.prompt.run({ prompt = "Run: " }, mypromptbox[mouse.screen], awful.util.spawn, awful.completion.bash, awful.util.getdir("cache") .. "/history")
end):add()

keybinding({ modkey }, "F4", function ()
	awful.prompt.run({ prompt = "Run Lua code: " }, mypromptbox[mouse.screen], awful.util.eval, awful.prompt.bash,awful.util.getdir("cache") .. "/history_eval")
end):add()

keybinding({ modkey, "Ctrl" }, "i", function ()
	local s = mouse.screen
	if mypromptbox[s].text then
		mypromptbox[s].text = nil
	elseif client.focus then
		mypromptbox[s].text = nil
		if client.focus.class then
			mypromptbox[s].text = "Class: " .. client.focus.class .. " "
		end
		if client.focus.instance then
			mypromptbox[s].text = mypromptbox[s].text .. "Instance: ".. client.focus.instance .. " "
		end
		if client.focus.role then
			mypromptbox[s].text = mypromptbox[s].text .. "Role: ".. client.focus.role
		end
	end
end):add()

-- Client awful tagging: this is useful to tag some clients and then do stuff like move to tag on them
keybinding({ modkey }, "m", awful.client.togglemarked):add()

for i = 1, keynumber do
	keybinding({ modkey, "Shift" }, "F" .. i,
		function ()
			local screen = mouse.screen
			if tags[screen][i] then
				for k, c in pairs(awful.client.getmarked()) do
					awful.client.movetotag(tags[screen][i], c)
				end
			end
	end):add()
end
-- }}}

-- {{{ Hooks
-- Hook function to execute when focusing a client.
awful.hooks.focus.register(function (c)
	if not awful.client.ismarked(c) then
		c.border_width = 3
		c.border_color = beautiful.border_focus
	end
	c.opacity = 1.0
end)

-- Hook function to execute when unfocusing a client.
awful.hooks.unfocus.register(function (c)
	if not awful.client.ismarked(c) then
		c.border = 0
		c.border_color = beautiful.border_normal
	end
	c.opacity = 0.8
end)

-- Hook function to execute when marking a client
awful.hooks.marked.register(function (c)
	c.border_color = beautiful.border_marked
end)

-- Hook function to execute when unmarking a client.
awful.hooks.unmarked.register(function (c)
	c.border_color = beautiful.border_focus
end)

-- Hook function to execute when the mouse enters a client.
awful.hooks.mouse_enter.register(function (c)
	-- Sloppy focus, but disabled for magnifier layout
	-- if awful.layout.get(c.screen) ~= "magnifier"
	--	and awful.client.focus.filter(c) then
	--	client.focus = c
	-- end
end)

-- Hook function to execute when a new client appears.
awful.hooks.manage.register(function (c)
	if use_titlebar then
		-- Add a titlebar
		awful.titlebar.add(c, { modkey = modkey })
	end

	if c.type == "dialog" then
		awful.titlebar.add(c, { modkey = modkey })
	end

	-- Add mouse bindings
	c:buttons({
		button({ }, 1, function (c) client.focus = c; c:raise() end),
		button({ modkey }, 1, function (c) c:mouse_move() end),
		button({ modkey }, 3, function (c) c:mouse_resize() end)
	})
	-- New client may not receive focus
	-- if they're not focusable, so set border anyway.
	c.border_width = beautiful.border_width
	c.border_color = beautiful.border_normal

	-- Check if the application should be floating.
	local cls = c.class
	local inst = c.instance
	if floatapps[cls] then
		c.floating = floatapps[cls]
	elseif floatapps[inst] then
		c.floating = floatapps[inst]
	end

	-- Check application->screen/tag mappings.
	local target
	if apptags[cls] then
		target = apptags[cls]
	elseif apptags[inst] then
		target = apptags[inst]
	end
	if target then
		c.screen = target.screen
		awful.client.movetotag(tags[target.screen][target.tag], c)
		awful.tag.viewonly(tags[target.screen][target.tag])
	end

	-- Do this after tag mapping, so you don't see it on the wrong tag for a split second.
	client.focus = c

	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- awful.client.setslave(c)

	-- Honor size hints: if you want to drop the gaps between windows, set this to false.
	c.honorsizehints = false
end)

-- Hook function to execute when arranging the screen.
-- (tag switch, new client, etc)
awful.hooks.arrange.register(function (screen)
	local layout = awful.layout.get(screen)
	if layout then
		mylayoutbox[screen].image = image(beautiful["layout_" .. layout])
	else
		mylayoutbox[screen].image = nil
	end

	-- Give focus to the latest client in history if no window has focus
	-- or if the current window is a desktop or a dock one.
	if not client.focus then
		local c = awful.client.focus.history.get(screen, 0)
		if c then client.focus = c end
	end

	if client.class == "gedit" then client.stick = false end

	-- Uncomment if you want mouse warping
	--[[
	if client.focus then
		local c_c = client.focus:fullgeometry()
		local m_c = mouse.coords()

		if m_c.x < c_c.x or m_c.x >= c_c.x + c_c.width or
			m_c.y < c_c.y or m_c.y >= c_c.y + c_c.height then
			if table.maxn(m_c.buttons) == 0 then
				mouse.coords({ x = c_c.x + 5, y = c_c.y + 5})
			end
		end
	end
	]]
end)

-- Hook called every second
awful.hooks.timer.register(1, function ()
	clockbox.text = " " .. os.date("%X %x", os.time() + 3600*8) .. " "
end)
-- }}}

local calendar = nil
local offset = 0

function remove_calendar()
if calendar ~= nil then
    naughty.destroy(calendar)
    calendar = nil
    offset = 0
end
end

function add_calendar(inc_offset)
	local save_offset = offset
	remove_calendar()
	offset = save_offset + inc_offset
	local datespec = os.date("*t")
	datespec = datespec.year * 12 + datespec.month - 1 + offset
	datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
	local cal = awful.util.pread("cal -m " .. datespec)
	calendar = naughty.notify({
		text = string.format('<span font_desc="%s">%s</span>', "Monaco 9", cal),
		timeout = 0, 
		hover_timeout = 0.5,
		width = 160, 
		position = "bottom_right"
	})
end

-- change clockbox for your clock widget (e.g. mytextbox)
clockbox.mouse_enter = function()
	add_calendar(0)
end
clockbox.mouse_leave = remove_calendar

clockbox:buttons({
button({ }, 4, function()
    add_calendar(-1)
end),
button({ }, 5, function()
    add_calendar(1)
end),
})

