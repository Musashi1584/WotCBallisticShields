class X2DownloadableContentInfo_WotCBallisticShields extends X2DownloadableContentInfo;

static function UpdateAnimations(out array<AnimSet> CustomAnimSets, XComGameState_Unit UnitState, XComUnitPawn Pawn)
{
	local X2WeaponTemplate PrimaryWeaponTemplate, SecondaryWeaponTemplate;
	local AnimSet AnimSetIter;
	local int i;
	local string AnimSetToLoad;

	if (!UnitState.IsSoldier())
	{
		return;
	}

	PrimaryWeaponTemplate = X2WeaponTemplate(UnitState.GetPrimaryWeapon().GetMyTemplate());
	SecondaryWeaponTemplate = X2WeaponTemplate( UnitState.GetSecondaryWeapon().GetMyTemplate());
	
	if (SecondaryWeaponTemplate.WeaponCat == 'shield')
	{
		switch (PrimaryWeaponTemplate.WeaponCat)
		{
			case 'rifle':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_AssaultRifle'";
				break;
			case 'sidearm':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_AutoPistol'";
				break;
			case 'pistol':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_Pistol'";
				break;
			case 'shotgun':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_Shotgun'";
				break;
			case 'bullpup':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_SMG'";
				break;
			case 'sword':
				AnimSetToLoad = "AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_Sword'";
				break;
		}

		if (AnimSetToLoad != "")
		{
			CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype(AnimSetToLoad)));
		}

		CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("AnimSet'WoTC_Shield_Animations.Anims.AS_Shield_Armory'")));
	}
}

static function AddAnimSet(XComUnitPawn Pawn, AnimSet AnimSetToAdd)
{
	if (Pawn.Mesh.AnimSets.Find(AnimSetToAdd) == INDEX_NONE)
	{
		Pawn.Mesh.AnimSets.AddItem(AnimSetToAdd);
		//`LOG(GetFuncName() @ "adding" @ AnimSetToAdd,, 'RPG');
	}
}