util.AddNetworkString("pKeysAdminMenu")
util.AddNetworkString("pKeysDestroyKey")
util.AddNetworkString("pKeysGenerateKey")
util.AddNetworkString("pKeysUserMenu")
util.AddNetworkString("pKeysRedeemKey")

require("mysqloo")
if(mysqloo) then
	MsgN("Mysqlo has succesfully been included")
else
	MsgN("Mysqloo couldn't be included. Check that you have the module")
	return
end
--Make sure that the folder to hold keys in actually exists
local db = mysqloo.connect("host", "user", "password", "database", 3306)
function db:onConnected()
	print("Succesfully connected")
end

--Helper function to update easily without repeating code
local function SendGUI( ply )
	local hashes = {}
	local q = db:query("SELECT * FROM key_hash")
	
	
	function q:onError(q, err, sql)
		print("We got an error")
		print(err .. "\n")
		return
	end
	function q:onSuccess()
		local data = self:getData()
		for k, v in pairs(data) do
			table.insert(hashes, {hash=v.hash, reward=v.reward})	
		end
			net.Start("pKeysAdminMenu")
				net.WriteTable( hashes )
			net.Send( ply )
	end
	q:start()
end

hook.Add("PlayerSay", "pKeysCommand", function( ply, text, team )
	if (string.sub( text, 1, 3 ) == "!pk") then
	
		--If the player has the required rank then let them
		--open the generate menu, else let them open the
		--redeem menu.
		
		if table.HasValue( pKey.permissions, ply:GetUserGroup() ) then
			SendGUI( ply )
		else
			net.Start("pKeysUserMenu")
			net.Send( ply )
		end
		
		--Prevent the command showing in chat
		return ""
	end
end)

net.Receive( "pKeysDestroyKey", function( len, ply )
	--Only continue if the player has correct permissions
	if not table.HasValue( pKey.permissions, ply:GetUserGroup() ) then return end

	local key = net.ReadString()
	local re = db:query("DELETE FROM `key_hash` WHERE `hash`='".. db:escape(key) .."'")
		function re:onSuccess()
			print("We succesfully removed the key(" .. key .. ")")
			SendGUI(ply)
		end
		function re:onError(q,err)
			print(err)
		end
		re:start()
end )

net.Receive( "pKeysGenerateKey", function( len, ply )
	--Only continue if the player has correct permissions
	if not table.HasValue( pKey.permissions, ply:GetUserGroup() ) then return end
	
	local rank = net.ReadString()
	
	--Make sure the rank that's being generated is allowed
	--to have a key generated for it
	if table.HasValue( pKey.canGenerate, rank ) then
		local q = db:query("INSERT INTO `key_hash` (`hash`, `reward`) VALUES('" .. db:escape(generateKey()) .. "', '".. rank .."')");
		function q:onSuccess()
			print("Succesfully inserted a new hash");
		end
		function q:onError(q, err, sql)
			print("We encountered an error while inserting new data");
			print(err)
			
			return 
		end
		q:start()
		print("started the query")
	end
	SendGUI( ply )
end )

function generateKey()
	--Thanks to ^seth: 
	--http://facepunch.com/showthread.php?t=1072047&p=28755362&viewfull=1#post28755362
	
	--Essentially this function just generates a bunch
	--of random characters.
	local str = string.char(math.random(35, 41))
	for i=1, 5 do
		str = str .. string.char(math.random(97, 122))
	end
	for i=1, 5 do
		str = str .. string.char(math.random(63, 91))
	end
	for i=1, 5 do
		str = str .. string.char(math.random(97, 122))
	end	
	for i=1, 3 do
		str = str .. string.char(math.random(48, 57))
	end
	for i=1, 2 do
		str = str .. string.char(math.random(35, 41))
	end	
	
	return str
end

net.Receive( "pKeysRedeemKey", function( len, ply )
	local text = net.ReadString()
	--Setup the cooldown if this is the first time
	if not ply.cooldown then
		ply.cooldown = CurTime() - 1
	end
	
	--If the cooldown is still active, notify the player
	if ply.cooldown > CurTime() then
		if pKey.darkRP then
			DarkRP.notify( ply, 1, 3, pKey.cooldownMessage )
		else
			ply:ChatPrint( pKey.cooldownMessage )
		end
		return
	end

	--Set the cooldown
	ply.cooldown = CurTime() + pKey.cooldownTime
		
	--Find the files with that key name
	local q = db:query("SELECT * FROM `key_hash` WHERE `hash`='".. db:escape(text) .."'")
	function q:onSuccess()
		local data = q:getData()
		PrintTable(data)
		if #data > 0 then
		--Read the contents of the file	
		--Add the user to the rank
		RunConsoleCommand( "ulx", "adduser", ply:Nick(), data[1].reward )
		
		--Since they're redeeming a key, remove it
		local re = db:query("DELETE FROM `key_hash` WHERE `hash`='".. db:escape(text) .."'")
		function re:onSuccess()
			print("We succesfully removed the key")
		end
		function re:onError(q,err)
			print(err)
		end
		re:start()
		--Notify the user
		if pKey.darkRP then
			DarkRP.notify( ply, 0, 3, pKey.added .. tostring(data[1].reward) )
		else
			ply:ChatPrint( pKey.added .. tostring(data[1].reward) )
		end
	else
		--If we couldn't find the key, tell the user
		if pKey.darkRP then
			DarkRP.notify( ply, 1, 3, pKey.notFound )
		else
			ply:ChatPrint( pKey.notFound )
		end
	end
	end
	function q:onError(q, err)
		print(err)
	end
	q:start()
end)
db:connect()
