class X2Effect_ShieldAim extends X2Effect_Persistent;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo		ShotModifier;
	local XComGameState_Item	SourceWeapon;
	local X2WeaponTemplate		WeaponTemplate;

	//	If the ability comes from the same item as this effect was applied by (i.e. the Ballistic Shield)
	if (EffectState.ApplyEffectParameters.ItemStateObjectRef.ObjectID == AbilityState.SourceWeapon.ObjectID)
	{
		SourceWeapon = AbilityState.GetSourceWeapon();
		if (SourceWeapon != none)
		{
			WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
			if (WeaponTemplate != none)
			{
				if (WeaponTemplate.WeaponCat == 'shield')
				{
					switch (WeaponTemplate.WeaponTech)
					{
						case 'conventional':
							ShotModifier.Value = class'X2Item_Shield'.default.SHIELD_CV_AIM;
							break;
						case 'magnetic':
							ShotModifier.Value = class'X2Item_Shield'.default.SHIELD_MG_AIM;
							break;
						case 'beam':
							ShotModifier.Value = class'X2Item_Shield'.default.SHIELD_BM_AIM;
							break;
						default:
							return;
					}	
				}
				else if (WeaponTemplate.WeaponCat == 'spark_shield')
				{
					switch (WeaponTemplate.WeaponTech)
					{
						case 'conventional':
							ShotModifier.Value = class'X2Item_Shield'.default.SPARK_SHIELD_CV_AIM;
							break;
						case 'magnetic':
							ShotModifier.Value = class'X2Item_Shield'.default.SPARK_SHIELD_MG_AIM;
							break;
						case 'beam':
							ShotModifier.Value = class'X2Item_Shield'.default.SPARK_SHIELD_BM_AIM;
							break;
						default:
							return;
					}
				}
				if (ShotModifier.Value != 0)
				{
					ShotModifier.ModType = eHit_Success;
					ShotModifier.Reason = class'XLocalizedData'.default.WeaponAimBonus;
					ShotModifiers.AddItem(ShotModifier);
				}
			}
		}
	}
}

defaultproperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "X2Effect_ShieldAim_Effect"
}