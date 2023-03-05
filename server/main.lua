local AllowList = {}

function loadAllowList()
	AllowList = nil

	local List = LoadResourceFile(GetCurrentResourceName(),'players.json')
	if List then
		AllowList = json.decode(List)
	end
end

loadAllowList()

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
		if #(GetPlayers()) < Config.MinPlayer then
			deferrals.done()
			return
		end
		deferrals.defer()

		local playerId, kickReason = source, "There Was An Error, Please Contact the server owner!"

		-- Letting the user know what's going on.
		deferrals.update(TranslateCap('allowlist_check'))

		-- Needed, not sure why.
		Wait(100)

		local identifier = ESX.GetIdentifier(playerId)

		if AllowList and #AllowList == 0 then
			kickReason = ('[ESX] %s'):format(TranslateCap('allowlist_empty'))
		elseif not identifier then
			kickReason = ('[ESX] %s'):format(TranslateCap('license_missing'))
		elseif not AllowList[identifier] then
			kickReason = ('[ESX] %s'):format(TranslateCap('not_allowlist'))
		end
		if kickReason then goto continue end
		deferrals.done()
		:: continue ::
		deferrals.done(kickReason)
end)

ESX.RegisterCommand('alrefresh', 'admin', function(xPlayer, args)
	loadAllowList()
	print('[^2INFO^7] Allowlist ^5Refreshed^7!')
end, true, {help = TranslateCap('help_allowlist_load')})

ESX.RegisterCommand('aladd', 'admin', function(xPlayer, args, showError)
	args.license = args.license:lower()

	if AllowList[args.license] then
			showError('The player is already allowlisted on this server!')
	else
		AllowList[args.license] = true
		SaveResourceFile(GetCurrentResourceName(), 'players.json', json.encode(AllowList))
		loadAllowList()
	end
end, true, {help = TranslateCap('help_allowlist_add'), validate = true, arguments = {
	{name = 'license', help = 'the player license', type = 'string'}
}})

ESX.RegisterCommand('alremove', 'admin', function(xPlayer, args, showError)
	args.license = args.license:lower()

	if AllowList[args.license] then
		AllowList[args.license] = nil
		SaveResourceFile(GetCurrentResourceName(), 'players.json', json.encode(AllowList))
		loadAllowList()
	else
		showError('Identifier is not Allowlisted on this server!')
	end
end, true, {help = TranslateCap('help_allowlist_add'), validate = true, arguments = {
	{name = 'license', help = 'the player license', type = 'string'}
}})
