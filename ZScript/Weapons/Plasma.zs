class JM_PlasmaRifle : JMWeapon Replaces PlasmaRifle
{
	action void JM_AddHeatBlastCharge()
	{
		int h = CountInv("HeatBlastShotCount");
		switch(h)
		{
			case 15:
				A_GiveInventory("HeatBlastLevel",1);
				A_StartSound("plasma/heatlevel1",10);
				break;
			case 30:
				A_GiveInventory("HeatBlastLevel",1);
				A_StartSound("plasma/heatlevel2",10);
				break;
			case 45:
				if(CountInv("HeatBlastFullyCharged") < 1)
				{
					A_GiveInventory("HeatBlastLevel",1);
					A_GiveInventory("HeatBlastFullyCharged",1);
					A_StartSound("plasma/heatlevel3",10);
				}
				break;
		}
	}
	
	action void JM_SetModeSprite(string s)
	{
		 let psp = Invoker.Owner.player.FindPSprite(PSP_WEAPON);
		 psp.sprite = GetSpriteIndex(s);
	}
	
	Default
	{
		Weapon.SelectionOrder 100;
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 60;
		Weapon.AmmoType1 "MO_Cell";
		Weapon.AmmoType2 "PlasmaAmmo";
		Inventory.PickupMessage "You got the Plasma Repeater! (Slot 6)";
		Inventory.PickupSound "weapons/plasma/pickup";
		Obituary "%o got melted by %k's Plasma Repeater.";
		Tag "Plasma Repeater";
	}
	States
	{
	ReadyToFire:
		2RGG A 0 A_JumpIfInventory("SuperHeatedRoundsReady",1,3);
		2RGG A 0 A_JumpIfInventory("HeatBlastFullyCharged",1,2);
		PRGG A 0;
		"####" A 1 JM_WeaponReady(WRF_ALLOWRELOAD);
		Loop;
	Deselect:
		PRGS DCBA 1; 
		PRGS A 0 A_Lower(12);
		Wait;
	Select:
		PRGG A 0;
		Goto ClearAudioAndResetOverlays;
	
	HeatBlastOverlay:
		PRLY B 1;
		Stop;
		
	ContinueSelect:
		PRGG A 0 A_SetInventory("PlasmaRifleCooldownCount",0);
		TNT1 AAAAAAAAAAAAAAAAAA 0 A_Raise();
		Goto Ready;
		
	Ready:
	SelectAnimation:
		TNT1 A 0 A_StartSound("weapons/plasma/equip",1);
		PRGS ABCD 1;
		Goto ReadyToFire;
		
	Fire:
		TNT1 A 0 JM_CheckMag("PlasmaAmmo");
		TNT1 A 0 JM_CheckForQuadDamage();
	FireContinue:
		TNT1 A 0 JM_CheckMag("PlasmaAmmo");
		2RGF A 0;
		3RGF A 0;
		PRGF A 0
		{
			if(CheckInventory("HeatBlastFullyCharged",1))
			{
				JM_SetModeSprite("2RGF");
			}
			else if(CheckInventory("SuperHeatedRoundsReady",1))
			{
				JM_SetModeSprite("3RGF");
			}
		}
		"####" A 1 
		{
			if(CountInv("SuperHeatedRoundsReady") == 1)
			{
				A_StartSound("weapons/plasma/superheatfire", CHAN_AUTO,CHANF_DEFAULT,0.7,ATTN_NORM);
				A_FireProjectile("JM_HeatedPlasmaBall", 0, FALSE, 0, 5, 0);
				A_Overlay(-60, "MuzzleFlashHeated");
				A_TakeInventory("SuperHeatedShotCounter",1);
				if(CountInv("SuperHeatedShotCounter") < 1)
				{
					A_TakeInventory("SuperHeatedRoundsReady",1);
				}
			}
			Else
			{
				A_StartSound("weapons/plasma/fire", CHAN_AUTO,CHANF_DEFAULT,1,ATTN_NORM,1.2);
				A_FireProjectile("JM_PlasmaBall", 0, FALSE, 0, 5, 0);
				A_Overlay(-60, "MuzzleFlash");
			}
			A_TakeInventory("PlasmaAmmo",1);
			A_GiveInventory("PlasmaRifleCooldownCount",1);
			A_GiveInventory("HeatBlastShotCount",1);
			JM_AddHeatBlastCharge();
		}
		"####" B 1
		{
			if(!GetCvar("mo_nogunrecoil"))
			{
			A_SetPitch(pitch-1.7,SPF_Interpolate);
			A_SetAngle(angle+.09,SPF_INTERPOLATE);
			}
		}
		"####" C 1;
		"####" A 0 A_JumpIf(PressingFire(), "FireContinue");
		"####" A 0 A_JumpIfInventory("PlasmaRifleCooldownCount",20,"Cooldown");
		"####" A 0 A_SetInventory("PlasmaRifleCooldownCount",0);
		"####" A 0 JM_CheckMag("PlasmaAmmo");
		Goto ReadyToFire;
	Flash:
		TNT1 A 4 Bright A_Light1;
		Goto LightDone;
		TNT1 B 4 Bright A_Light1;
		Goto LightDone;
	Spawn:
		PLAS A -1;
		Stop;
	
	Cooldown:
		2RGN ABCDEFGHIJKLMNOPQ 0;
		PRGN A 0
		{
			if(CheckInventory("SuperHeatedRoundsReady",1) || CheckInventory("HeatBlastFullyCharged",1))
			{
				JM_SetModeSprite("2RGN");
			}
		}
		"####" A 0 A_SetInventory("PlasmaRifleCooldownCount",0);
		"####" A 0 {
			A_StartSound("weapons/plasma/overheat",1);
			A_StartSound("weapons/plasma/cooldown",6);
			}
		"####" ABCDEFG 1;
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		"####" HH 1 
		{
			A_WeaponOffset(random(-1,1), random(31,33));
			A_SpawnItemEx("PlasmaCoolSmoke1",23, -13, 38, random(0,1), 0, 0);
		}
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		"####" HH 1 A_WeaponOffset(random(-2,2), random(31,33));
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		"####" HH 1 {
			A_WeaponOffset(random(-1,1), random(31,33));
			A_SpawnItemEx("PlasmaCoolSmoke1",23, -13, 38, random(0,1), 0, 0);
		}
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		"####" HH 1 A_WeaponOffset(random(-2,2), random(31,33));
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		"####" II 1 {
			A_WeaponOffset(random(-1,1), random(31,33));
			A_SpawnItemEx("PlasmaCoolSmoke2",23, -15, 38, random(0,1), 0, 0);
		}
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		"####" II 1 A_WeaponOffset(random(-2,2), random(31,33));
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,2);
		"####" II 1 {
			A_WeaponOffset(random(-1,1), random(31,33));
			A_SpawnItemEx("PlasmaCoolSmoke2",23, -15, 38, random(0,1), 0, 0);
		}
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		"####" II 1 A_WeaponOffset(random(-2,2), random(31,33));
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		"####" JJ 1 {
			A_WeaponOffset(random(-1,1), random(31,33));
			A_SpawnItemEx("PlasmaCoolSmoke3",23, -17, 38, random(0,1), 0, 0);
		}
		"####" JJ 1 A_WeaponOffset(random(-2,2), random(31,33));
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,2);
		"####" JJ 1 {
			A_WeaponOffset(random(-1,1), random(31,33));
			A_SpawnItemEx("PlasmaCoolSmoke3",23, -17, 38, random(0,1), 0, 0);
		}
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		"####" JJ 1 A_WeaponOffset(random(-2,2), random(31,33));
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		"####" KK 1 A_WeaponOffset(random(-1,1), random(31,33));
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,2);
		"####" KK 1 A_WeaponOffset(random(-2,2), random(31,33));
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		"####" KK 1 A_WeaponOffset(random(-1,1), random(31,33));
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		"####" KK 1 A_WeaponOffset(random(-2,2), random(31,33));
		"####" A 0 A_JumpIfInventory("MO_PowerSpeed",1,3);
		"####" K 1 A_WeaponOffset(0,32);
		"####" LMNOPQ 1 A_WeaponOffset(0,32);
		"####" A 0 A_SetInventory("PlasmaRifleCooldownCount",0);
		"####" A 0 A_JumpIfInventory("PlasmaAmmo",1,"ReadyToFire");
		Goto Reload;
	
	AltFire:
		TNT1 A 0;
		TNT1 A 0 {
			if(CountInv("HeatBlastFullyCharged") >= 1 || CountInv("SuperHeatedRoundsReady") >=1)
			{return ResolveState("FullBlast");}
			else
			{return ResolveState("CellDischarge");}
		}
		TNT1 A 0;
		Goto ReadyToFire;
	
	CellDischarge:
		TNT1 A 0 JM_CheckMag("PlasmaAmmo", "Cooldown");
		PRGF A 0;
		TNT1 A 0 A_JumpIf(JustReleased(BT_ALTATTACK), "CheckForCooldown");
		PRGF A 1 
		{
			if(CountInv("SuperHeatedRoundsReady") == 1)
			{
				A_StartSound("weapons/plasma/superheatfire", CHAN_AUTO,CHANF_DEFAULT,0.7,ATTN_NORM);
				A_FireProjectile("JM_HeatedPlasmaBall", 0, FALSE, 0, 5, 0);
				A_Overlay(-60, "MuzzleFlashHeated");
			}
			Else
			{
				A_StartSound("weapons/plasma/fire", CHAN_AUTO,CHANF_DEFAULT,1,ATTN_NORM,1.2);
				A_FireProjectile("JM_PlasmaBall", random(-4,4), FALSE, 0, random(3,5), 0, random(-3,3));
				A_Overlay(-60, "MuzzleFlash");
			}
			A_TakeInventory("PlasmaAmmo",1);
			A_GiveInventory("PlasmaRifleCooldownCount",1);
		}
		TNT1 A 0 A_JumpIf(JustReleased(BT_ALTATTACK), "CheckForCooldown");
		PRGF C 1
		{
			if(!GetCvar("mo_nogunrecoil"))
			{
			A_SetPitch(pitch-0.7,SPF_Interpolate);
			A_SetAngle(angle+.09,SPF_INTERPOLATE);
			}
		}
		TNT1 A 0 A_JumpIf(PressingAltFire(), "CellDischarge");
		Goto CheckForCooldown;
	
	CheckForCooldown:
		TNT1 A 0;
		TNT1 A 0 A_JumpIfInventory("PlasmaRifleCooldownCount",10, "Cooldown");
		TNT1 A 0 A_SetInventory("PlasmaRifleCooldownCount",0);
		Goto ReadyToFire;
		
	
/*	ActionSpecial:
		TNT1 A*/
			
	FullBlast:
		3RGF A 1 
		{
			A_StartSound("weapons/plasma/heatblast", CHAN_AUTO,CHANF_DEFAULT,1,ATTN_NORM,1.2);
			A_FireProjectile("JM_SuperHeatBlastMissile", 0, FALSE, 0, 5, 0);
			A_TakeInventory("PlasmaAmmo",15);
			A_TakeInventory("HeatBlastLevel",3);
			A_TakeInventory("HeatBlastFullyCharged",1);
			A_TakeInventory("HeatBlastShotCount",45);
			A_GiveInventory("SuperHeatedRoundsReady",1);
			A_GiveInventory("SuperHeatedShotCounter",25);
		}
		3RGF B 1
		{
			if(!GetCvar("mo_nogunrecoil"))
			{
			A_SetPitch(pitch-2.7,SPF_Interpolate);
			A_SetAngle(angle+.09,SPF_INTERPOLATE);
			}
		}
		2RGA A 1
		{
			if(!GetCvar("mo_nogunrecoil"))
			{
			A_SetPitch(pitch-2.7,SPF_Interpolate);
			A_SetAngle(angle+.09,SPF_INTERPOLATE);
			}
		}
		2RGA BCDEFF 1;
		2RGA EDCBA 1;
		Goto Cooldown;
	Reload:
		PSTG A 0 A_JumpIfInventory("PlasmaRifleCooldownCount",20,"Cooldown");
		PSTG A 0 A_JumpIfInventory("PlasmaAmmo",60,"ReadyToFire");
		PSTG A 0 A_JumpIfInventory("MO_Cell",1,1);
		goto ReadyToFire;
		PRL1 AB 1 JM_WeaponReady(WRF_NOFIRE);
		PSTF A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		PRL1 CDE 1 JM_WeaponReady(WRF_NOFIRE);
		PRL3 AB 1 JM_WeaponReady(WRF_NOFIRE);
		PSTF A 0 A_JumpIfInventory("MO_PowerSpeed",1,5);
		PRL3 CCCCDE 1 JM_WeaponReady(WRF_NOFIRE);
		PSTF A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		PRL3 F 1 JM_WeaponReady(WRF_NOFIRE);
		PRL3 G 1 JM_WeaponReady(WRF_NOFIRE);
		PSTF A 0 A_JumpIfInventory("MO_PowerSpeed",1,3);
		PRL3 HHHI 1 JM_WeaponReady(WRF_NOFIRE);
		PRGA A 0 A_StartSound("weapons/plasma/cellout",2);
		PRL3 JKLMN 1 JM_WeaponReady(WRF_NOFIRE);
		PRGN A 0 A_JumpIf(CountInv("PlasmaAmmo") >= 1, 2);
		PRGN A 0 A_SpawnItemEx("EmptyCell",46, -2, 15, random(-1,3), random(3,6), random(3,5));
		PSTF A 0 A_JumpIfInventory("MO_PowerSpeed",1,4);
		PRL3 OOOO 1 JM_WeaponReady(WRF_NOFIRE);
		PSTF A 0 A_JumpIfInventory("MO_PowerSpeed",1,3);
		PRL1 GGGGGH 1 JM_WeaponReady(WRF_NOFIRE);
		PSTF A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		PRL1 IJKL 1 JM_WeaponReady(WRF_NOFIRE);
		PRL1 M 1 A_StartSound("weapons/plasma/cellin", 0);
		PRL1 N 1 JM_WeaponReady(WRF_NOFIRE);
		PRL1 O 1	A_StartSound("weapons/plasma/goingtoturnon", 0);
		Goto ReloadLoop;
	DoneReload:
		PRL1 PQ 1 JM_WeaponReady(WRF_NOFIRE);
		PRL1 R 1 A_StartSound("weapons/plasma/poweredon", 4);
		PRL1 STUVWX 1 JM_WeaponReady(WRF_NOFIRE);
		PSTF A 0 A_JumpIfInventory("MO_PowerSpeed",1,5);
		PRL1 YYYYYYYYZ 1 JM_WeaponReady(WRF_NOFIRE);
		PSTF A 0 A_JumpIfInventory("MO_PowerSpeed",1,1);
		PRL2 ABCD 1 JM_WeaponReady(WRF_NOFIRE);
		Goto ReadyToFire;
	
	ReloadLoop:
		PISG A 0;
		PISG A 0 A_JumpIfInventory("PlasmaAmmo",60,"DoneReload");
		TNT1 A 0 A_JumpIfInventory("MO_Cell",1,1);
		PISG A 0 
		{
			A_TakeInventory("MO_Cell",1);
			A_GiveInventory("PlasmaAmmo",1);
		}
		Loop;
		
	FlashKick:
	FlashAirKick:
		PRL1 ABCDE 1;
		PRL3 ABCCBA 1;
		PRL1 EDCBA 1;
		Goto ReadyToFire;
	
	MuzzleFlash:
		TNT1 A 0 A_Jump(255, "M1","M2","M3","M4", "M5", "M6");
	M1:
		PRMZ AB 1 BRIGHT;
		Stop;
	M2:
		PRMZ CD 1 BRIGHT;
		Stop;
	M3:
		PRMZ EB 1 BRIGHT;
		Stop;
	M4:
		PRMZ AD 1 BRIGHT;
		Stop;
	M5:
		PRMZ CB 1 BRIGHT;
		STOP;
	M6:
		PRMZ ED 1 BRIGHT;
		STOP;
	
	MuzzleFlashHeated:
		TNT1 A 0 A_Jump(255, "HM1","HM2","HM3","HM4", "HM5", "HM6");
	HM1:
		PRMZ FG 1 BRIGHT;
		Stop;
	HM2:
		PRMZ HI 1 BRIGHT;
		Stop;
	HM3:
		PRMZ JG 1 BRIGHT;
		Stop;
	HM4:
		PRMZ FI 1 BRIGHT;
		Stop;
	HM5:
		PRMZ HG 1 BRIGHT;
		STOP;
	HM6:
		PRMZ JI 1 BRIGHT;
		STOP;
	}
}

class PlasmaRifleCooldownCount : Inventory
{
	Default
	{
		Inventory.Amount 1;
		Inventory.MaxAmount 20;
	}
}

class PlasmaAmmo : Ammo
{
	Default
	{
		Inventory.Amount 0;
		Inventory.MaxAmount 60;
		Ammo.BackpackAmount 0;
		Ammo.BackpackMaxAmount 60;
		Inventory.Icon "PLASA0";
		+INVENTORY.IGNORESKILL;
	}
}

class JM_PlasmaBall : FastProjectile replaces PlasmaBall
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 70;
 //		Damage 30;
		DamageFunction 40;
		Scale 0.4;
		Projectile;
		+RANDOMIZE
		+ZDOOMTRANS
		RenderStyle "Add";
		Alpha 0.85;
		SeeSound "None";
		DeathSound "weapons/plasma/ballexp";
		Obituary "$OB_MPPLASMARIFLE";
		DamageType "Plasma";
		+NOTELEPORT;
		Decal "Scorch";
	}
	States
	{
 	Spawn:
		PB01 ABCDE 1 Bright Light("PlasmaBallLight");
		Loop;
	Death:
	    NULL A 0;
		NULL A 0 A_Scream();
		NULL A 0; //A_SpawnDebris("PlasmaSpark")
		NULL A 0 A_SpawnItem("MO_PlasmaSmoke");
		TNT1 A 0; //bright A_SpawnItem("BoomBlue")
		TNT1 AAA 0 A_SpawnItemEx("BlueLightningMini", Random(-4, 4), Random(-4, 4), Random(-4, 4), 0, 0, 0, 0, 0, 64);
		TNT1 AA 0 A_SpawnItemEx("BlueLightningTiny", Random(-4, 4), Random(-4, 4), Random(-4, 4), 0, 0, 0, 0, 0, 128);
		TNT1 A 0 A_SpawnItemEx("BlueLightningSmall", Random(-4, 4), Random(-4, 4), Random(-4, 4), 0, 0, 0, 0, 0, 192);
		TNT1 A 0 A_SpawnItem("PlasmaExplosion");
		Stop;
	}
}

class JM_HeatedPlasmaBall : JM_PlasmaBall
{
	Default
	{
		Obituary "%o was scorched by %k's Heated Plasma Repeater.";
		DeathSound "weapons/plasma/htballexp";
	}
	States
	{
 	Spawn:
		PB02 ABCDE 1 Bright Light("HeatedPlasmaBallLight");
		Loop;
	Death:
		NULL A 0;
		NULL A 0; //A_SpawnDebris("PlasmaSpark")
		NULL A 0 A_Scream();
		NULL A 0 A_SpawnItem("MO_PlasmaSmoke");
		TNT1 A 0; //bright A_SpawnItem("BoomBlue")
		TNT1 AAA 0 A_SpawnItemEx("RedLightningMini", Random(-4, 4), Random(-4, 4), Random(-4, 4), 0, 0, 0, 0, 0, 64);
		TNT1 AA 0 A_SpawnItemEx("RedLightningTiny", Random(-4, 4), Random(-4, 4), Random(-4, 4), 0, 0, 0, 0, 0, 128);
		TNT1 A 0 A_SpawnItemEx("RedLightningSmall", Random(-4, 4), Random(-4, 4), Random(-4, 4), 0, 0, 0, 0, 0, 192);
		TNT1 A 0 A_SpawnItem("HeatedPlasmaExplosion");
		Stop;
	}
}

class PlasmaExplosion : BaseVisualSFX
{
	Default
	{
	  Radius 0;
	  Height 0;
	  RenderStyle "Add";
	  Scale 0.2;
	  Alpha 0.7;
	}
	States
	  {
	  Spawn:
		NULL A 0;
		NULL A 0; //A_SpawnItem("BlueExplosionFlare")
		PLXP ABCDEFGH 2 Bright A_FadeOut(0.05);
		stop;
	  }
}

class HeatedPlasmaExplosion : PlasmaExplosion
{
	States
	  {
	  Spawn:
		NULL A 0;
		NULL A 0; //A_SpawnItem("BlueExplosionFlare")
		PHXP ABCDEFGH 2 Bright A_FadeOut(0.05);
		stop;
	  }
}

class JM_HeatBlastMissile : FastProjectile
{
	Default
	{
		Speed 35;
		DamageFunction (60);
		DeathSound "NULLSND";
		Radius 13;
		Height 8;
		Scale 0.4;
		Projectile;
		+RANDOMIZE
		+ZDOOMTRANS
		RenderStyle "Add";
		Alpha 0.85;
		SeeSound "None";
		Obituary "%o was blasted away by %k's Heat Blast.";
		DamageType "Plasma";
		+NOTELEPORT;
		Decal "Scorch";
		+ripper;
//		RipperCount 3;
	}
	States
	{
		Spawn:
		TNT1 A 0;
		TNT1 A 0 A_SpawnItemEx("HeatBlastShockwave2",15,0,0,6,0,0);
		TNT1 A 0 A_SpawnItemEx("HeatBlastShockwave",6,0,0,3,0,0);
		TNT1 A 0 
		{
				A_SpawnItemEx("BlueLightningLarge");
				A_SpawnItemEx("BlueLightningSmall");
				A_SpawnItemEx("BlueLightningMedium");
				A_Explode(90,150,0);
		}
		TNT1 A 0 A_Explode(90,150,0);
		TNT1 A 0 A_Quake(2,4,0,4,0);
		TNT1 A 2;
		TNT1 A 0 
		{
				A_SpawnItemEx("BlueLightningLarge",8,0,0);
				A_SpawnItemEx("BlueLightningSmall",8,0,0);
				A_SpawnItemEx("BlueLightningMedium",8,0,0);
		}
		TNT1 A 1;
		Stop;
		Death:
			TNT1 A 1 A_Explode(10,40,0);
			STOP;
	}
}

class JM_SuperHeatBlastMissile : JM_HeatBlastMissile
{
	default{Damagefunction(random(120, 150));}
	States
	{
		Spawn:
		TNT1 A 1;	
		TNT1 A 0 A_Explode(90,200,0);
		TNT1 A 0 A_SpawnItemEx("HeatBlastShockwave2Red",15,0,0,6,0,0);
		TNT1 A 0 A_SpawnItemEx("HeatBlastShockwaveRed",6,0,0,3,0,0);
		TNT1 A 0 A_Quake(2,4,0,4,0);
		TNT1 A 0 
		{
				A_SpawnItemEx("RedLightningLarge");
				A_SpawnItemEx("RedLightningSmall");
				A_SpawnItemEx("RedLightningMedium");
		}
		TNT1 A 2;
		TNT1 A 0 
		{
				A_SpawnItemEx("RedLightningLarge",8,0,0);
				A_SpawnItemEx("RedLightningSmall",8,0,0);
				A_SpawnItemEx("RedLightningMedium",8,0,0);
		}
		TNT1 A 1;
		Stop;
	}
}

class HeatBlastShotCount : Inventory
{Default{Inventory.MaxAmount 45;}}
class HeatBlastLevel : Inventory
{Default{Inventory.MaxAmount 3;}}
class HeatBlastFullyCharged : MO_ZSToken{}
class SuperHeatedRoundsReady : MO_ZSToken{}
class SuperHeatedShotCounter : Inventory
{Default{Inventory.MaxAmount 25;}}