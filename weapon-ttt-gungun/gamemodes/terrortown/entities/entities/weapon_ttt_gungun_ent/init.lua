AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.GunModels = {
	{"models/weapons/w_pist_elite_single.mdl", "weapons/elite/elite-1.wav", 38}, 
	{"models/weapons/w_mach_m249para.mdl", "weapons/m249/m249-1.wav", 32},
	{"models/weapons/w_pist_deagle.mdl", "weapons/deagle/deagle-1.wav", 50},
	{"models/weapons/w_pist_fiveseven.mdl", "weapons/fiveseven/fiveseven-1.wav", 24},
	{"models/weapons/w_pist_glock18.mdl", "weapons/glock/glock18-1.wav", 30},
	{"models/weapons/w_pist_p228.mdl", "weapons/p228/p228-1.wav", 38},
	{"models/weapons/w_pist_usp.mdl", "weapons/usp/usp_unsil-1.wav", 32},
	{"models/weapons/w_rif_ak47.mdl", "weapons/ak47/ak47-1.wav", 36},
	{"models/weapons/w_rif_aug.mdl", "weapons/aug/aug-1.wav", 28},
	{"models/weapons/w_rif_famas.mdl", "weapons/famas/famas-1.wav", 30},
	{"models/weapons/w_rif_galil.mdl", "weapons/galil/galil-1.wav", 29},
	{"models/weapons/w_rif_m4a1.mdl", "weapons/m4a1/m4a1_unsil-1.wav", 32},
	{"models/weapons/w_rif_sg552.mdl", "weapons/sg552/sg552-1.wav", 32},
	{"models/weapons/w_smg_mac10.mdl", "weapons/mac10/mac10-1.wav", 29},
	{"models/weapons/w_smg_mp5.mdl", "weapons/mp5navy/mp5-1.wav", 32},
	{"models/weapons/w_smg_p90.mdl", "weapons/p90/p90-1.wav", 26},
	{"models/weapons/w_smg_ump45.mdl", "weapons/ump45/ump45-1.wav", 35},
	{"models/weapons/w_snip_awp.mdl", "weapons/awp/awp1.wav", 115},
	{"models/weapons/w_snip_g3sg1.mdl", "weapons/g3sg1/g3sg1-1.wav", 80},
	{"models/weapons/w_snip_scout.mdl", "weapons/scout/scout_fire-1.wav", 74},
	{"models/weapons/w_snip_sg550.mdl", "weapons/sg550/sg550-1.wav", 69}
}

function ENT:Initialize()
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:PrecacheGibs()
	end

    local gun_damage = self.Damage
    local gun_sound = self.GunSound
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end

	self:SetUseType(SIMPLE_USE)

    for i = 1, 60 do
        timer.Simple((i / 3) * math.Rand(1, 5), function()
            if not IsValid(self) then return end

            self:EmitSound(gun_sound)

			phys:ApplyForceCenter(-phys:GetAngles():Forward() * 250)
			phys:ApplyForceOffset(VectorRand() * 200, phys:GetPos())

			local effect_data = EffectData()
			effect_data:SetOrigin(self:GetAttachment(1).Pos)
			effect_data:SetAngles(self:GetAngles())
			effect_data:SetEntity(self)
			effect_data:SetAttachment(1)
			util.Effect("MuzzleEffect", effect_data)

            self:FireBullets({
                Damage = gun_damage,
                Dir = self:GetAngles():Forward(),
                Src = self:GetPos()
            })
        end)
    end

    timer.Simple(30, function()
        if not IsValid(self) then return end

        self:EmitSound("physics/metal/metal_box_break" .. math.random(1, 2) .. ".wav")
		
		local effect_data = EffectData()
		effect_data:SetOrigin(self:GetPos())
		effect_data:SetAngles(self:GetAngles())
		effect_data:SetEntity(self)
		util.Effect("StunstickImpact", effect_data)

        self:Remove()
    end)
end