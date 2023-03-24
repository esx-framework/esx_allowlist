local allowList = {}

local function loadAllowList()
	allowList = {}

	local list = LoadResourceFile(GetCurrentResourceName(),'players.json')
	if list then
		allowList = json.decode(list)
	end
end

CreateThread(loadAllowList)

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
    local players = GetPlayers()
    if #players < Config.MinPlayer then return end
    
    deferrals.defer()

    local playerId, kickReason = source, nil

    deferrals.update(TranslateCap('allowlist_check'))

    Wait(0)

    local identifier = ESX.GetIdentifier(playerId)

    if ESX.Table.SizeOf(allowList) == 0 then
        kickReason = "[ESX] " .. TranslateCap('allowlist_empty')
    elseif not identifier then
        kickReason = "[ESX] " .. TranslateCap('license_missing')
    elseif not allowList[identifier] then
        kickReason = "[ESX] " .. TranslateCap('not_allowlist')
    end

    if kickReason then return deferrals.done(kickReason) end

    deferrals.done()
end)

ESX.RegisterCommand('alrefresh', 'admin', function(xPlayer, args)
	loadAllowList()
	print('[^2INFO^7] Allowlist ^5Refreshed^7!')
end, true, {help = TranslateCap('help_allowlist_load')})

ESX.RegisterCommand('aladd', 'admin', function(xPlayer, args, showError)
	args.license = args.license:lower()

	if allowList[args.license] then
		showError('The player is already allowlisted on this server!')
	else
		allowList[args.license] = true
		SaveResourceFile(GetCurrentResourceName(), 'players.json', json.encode(allowList))
		loadAllowList()
	end
end, true, {help = TranslateCap('help_allowlist_add'), validate = true, arguments = {
	{name = 'license', help = 'the player license', type = 'string'}
}})

ESX.RegisterCommand('alremove', 'admin', function(xPlayer, args, showError)
	args.license = args.license:lower()

	if allowList[args.license] then
		allowList[args.license] = nil
		SaveResourceFile(GetCurrentResourceName(), 'players.json', json.encode(allowList))
		loadAllowList()
	else
		showError('Identifier is not Allowlisted on this server!')
	end
end, true, {help = TranslateCap('help_allowlist_add'), validate = true, arguments = {
	{name = 'license', help = 'the player license', type = 'string'}
}})
