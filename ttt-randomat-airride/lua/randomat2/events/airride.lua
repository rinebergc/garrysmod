local EVENT = {}

util.AddNetworkString( "RandomatAirRideBegin" )
util.AddNetworkString( "RandomatAirRideEnd" )

EVENT.Title = "Air Ride"
EVENT.Description = "It's a race for survival!"
EVENT.id = "airride"
EVENT.Type = EVENT_TYPE_DEFAULT
EVENT.Categories = { "fun", "item", "largeimpact", "modelchange" }

function EVENT:Begin()
    net.Start( "RandomatAirRideBegin" )
    net.Broadcast()
    BroadcastLua( 'surface.PlaySound( "citytrial.ogg" )' )

    local models = { "models/kerbe/kerbe.mdl", "models/metaknight/metaknight.mdl", "models/kdedede_pm/kdedede_pm.mdl" }
    local playermodel = models[math.random(#models)]

    for _, ply in pairs( self:GetAlivePlayers() ) do
        Randomat:ForceSetPlayermodel( ply, playermodel )
        ply:Give( "weapon_ttt_detective_toy_car" )
    end

    self:AddHook( "PlayerSpawn", function( ply )
        timer.Simple(1, function()
            Randomat:ForceSetPlayermodel( ply, playermodel )
        end )
    end )
end

function EVENT:End()
    Randomat:ForceResetAllPlayermodels()

    net.Start( "RandomatAirRideEnd" )
    net.Broadcast()
end

Randomat:register( EVENT )