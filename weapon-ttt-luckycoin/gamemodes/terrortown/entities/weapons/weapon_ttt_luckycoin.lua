AddCSLuaFile()

SWEP.HoldType = "fist"

if CLIENT then
    SWEP.PrintName = "Lucky Coin"
    SWEP.Slot = 6
    SWEP.ViewModelFOV = 10
    SWEP.DrawCrosshair = false

    SWEP.EquipMenuData = {
        type = "Weapon",
        desc = "Flip a coin. Heads you heal 50hp. Tails you explode. You might also just lose it."
    };
    SWEP.Icon = "vgui/ttt/icon_luckycoin"
end

if SERVER then
    resource.AddFile("materials/vgui/ttt/icon_luckycoin.vmt")
end

SWEP.Base = "weapon_tttbase"

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/eurocoin.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.AllowDrop = true
SWEP.AmmoEnt = "none"
SWEP.CanBuy = { ROLE_DETECTIVE, ROLE_TRAITOR }
SWEP.InLoadoutFor = nil
SWEP.Kind = WEAPON_EQUIP1
SWEP.LimitedStock = false
SWEP.NoSights = true

local UseSound = Sound( "coinflip.ogg" )
local LoseSound = Sound( "coinclatter.ogg" )

function SWEP:Initialize()
	if CLIENT then
		self:AddHUDHelp( "RELOAD to flip your coin.", "", false)
	end
end

function SWEP:Deploy()
    if SERVER and IsValid(self:GetOwner()) then
        self:GetOwner():DrawViewModel(false)
    end
    self:DrawShadow(false)
    return true
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
    if self.ReloadingTime and CurTime() <= self.ReloadingTime then return end

    function GetWeightedRandomKey( tab )
        local sum = 0
        for _, chance in pairs( tab ) do
            sum = sum + chance
        end
        local select = math.random() * sum
        for key, chance in pairs( tab ) do
            select = select - chance
            if select < 0 then return key end
        end
    end

    local result = {
        heads = 45.00,
        tails = 45.00,
        neither = 10.00
    }

    if GetWeightedRandomKey( result ) == "heads" then
        self:EmitSound( UseSound )
        self:GetOwner():PrintMessage( HUD_PRINTTALK, "Heads! :)" )
        if ( self:GetOwner():Health() + 50 ) > 100 then
            self:GetOwner():SetHealth( 100 )
        else
            self:GetOwner():SetHealth( self:GetOwner():Health() + 50 )
        end
    elseif GetWeightedRandomKey( result ) == "tails" then
        self:EmitSound( UseSound )
        self:GetOwner():PrintMessage( HUD_PRINTTALK, "Tails! :(" )
        self:Remove()
        if SERVER then
            util.BlastDamage( self, self, self:GetPos(), 150, 200 )
            local effect = EffectData()
            effect:SetOrigin( self:GetPos() + Vector(0,0, 10) )
            effect:SetStart( self:GetPos() + Vector(0,0, 10) )
            util.Effect( "Explosion", effect, true, true )
        end
    elseif GetWeightedRandomKey( result ) == "neither" then
        self:EmitSound( LoseSound )
        self:GetOwner():PrintMessage( HUD_PRINTTALK, "Oops. You lost your coin..." )
        self:Remove()
    else
        print( "This message should not exist." )
    end

    self.ReloadingTime = CurTime() + 0.5
end