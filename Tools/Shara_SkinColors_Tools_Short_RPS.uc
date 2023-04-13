class Shara_SkinColors_Tools_Short_RPS extends Object
	abstract;

/*
	A short version of Shara_SkinColors_Tools including only functions referenced by mod scripts and their dependencies.
	RPS suffix means RideablePokemon_Script.
	All functions are written by Shararamosh.
*/

static function bool SetMaterialInstanceScalarValue(MaterialInstance inst, Name n, float f) //Optimized, includes IsInMapOrTransientPackage check to not accidentally change value on all child MaterialInstances.
{
	if (inst == None || !inst.IsInMapOrTransientPackage())
		return false;
	inst.SetScalarParameterValue(n, f);
	return true;
}

static function SetMaterialScalarValueMesh(MeshComponent comp, Name n, float f) //Calls SetMaterialInstanceScalarValue function for each MaterialInstance.
{
	local int i;
	if (comp == None)
		return;
	for (i = 0; i < comp.GetNumElements(); i++)
		SetMaterialInstanceScalarValue(MaterialInstance(comp.GetMaterial(i)), n, f);
}

static function bool SetMaterialInstanceScalarCurveValue(MaterialInstance inst, Name n, InterpCurveFloat ncf) //Optimized, includes IsInMapOrTransientPackage check to not accidentally change value on all child MaterialInstances.
{
	if (inst == None || !inst.IsInMapOrTransientPackage())
		return false;
	inst.SetScalarCurveParameterValue(n, ncf);
	return true;
}

static function bool SetMaterialInstanceTransitionEffect(MaterialInstance inst, Name n, InterpCurveFloat icf) //Optimized, includes IsInMapOrTransientPackage check to not accidentally change value on all child MaterialInstances.
{
	local MaterialInstanceTimeVarying MITV;
	if (!SetMaterialInstanceScalarCurveValue(inst, n, icf))
		return false;
	MITV = MaterialInstanceTimeVarying(inst);
	if (MITV != None)
		MITV.SetScalarStartTime(n, 0.0);
	return true;
}
	
static function SetTransitionEffectMesh(MeshComponent comp, Name n, float start, float end, float time, optional float mid = -1.0, optional float midtime = -1.0) //Calls SetMaterialInstanceTransitionEffect function for each MaterialInstance.
{
	local int i;
	local InterpCurveFloat icf;
	if (comp == None)
		return;
	if (mid >= 0.0 && midtime >= 0.0)
		icf = class'Hat_Math'.static.GenerateCurveFloat2(start, mid, end, midtime, time);
	else
		icf = class'Hat_Math'.static.GenerateCurveFloat(start, end, time);
	for (i = 0; i < comp.GetNumElements(); i++)
		SetMaterialInstanceTransitionEffect(MaterialInstance(comp.GetMaterial(i)), n, icf);
}	

static function ResetMaterials(MeshComponent comp)
{
	local int i;
	local SkeletalMeshComponent skmComp;
	local StaticMeshComponent stmComp;
	local bool IsDefaultMesh;
	if (comp == None)
		return;
	skmComp = SkeletalMeshComponent(comp);
	stmComp = StaticMeshComponent(comp);
	if (skmComp != None && skmComp.SkeletalMesh == skmComp.default.SkeletalMesh)
		IsDefaultMesh = true;
	else if (stmComp != None && stmComp.StaticMesh == stmComp.default.StaticMesh)
		IsDefaultMesh = true;
	for (i = 0; i < comp.GetNumElements(); i++)
	{
		if (IsDefaultMesh && i < comp.default.Materials.Length)
			comp.SetMaterial(i, comp.default.Materials[i]);
		else
			comp.SetMaterial(i, None);
	}
}

static function ConditionalInitMaterialInstancesMesh(MeshComponent comp) //Inits MaterialInstances on MeshComponent. Optimized: does not create unnecessary instances in case there's one already.
{
	local int i;
	local MaterialInterface mat;
	if (comp != None)
	{
		for (i = 0; i < comp.GetNumElements(); i++)
		{
			mat = comp.GetMaterial(i);
			if (mat == None)
				continue;
			mat = mat.GetMaterial();
			if (mat == Material'HatInTime_Characters.Materials.Invisible' || mat == Material'HatInTime_Characters.Materials.OccludedMaterial')
			{
				mat = GetActualMaterial(comp.GetMaterial(i));
				if (comp.GetMaterial(i) != mat)
					SetMaterialParentToInstance(comp, i, mat);
			}
			else
				ConditionalInitMaterialInstance(comp, i);
		}
	}
}

static function bool ConditionalInitMaterialInstance(MeshComponent comp, int i, optional out MaterialInstance CreatedInstance) //Inits one MaterialInstance on MeshComponent's Material with index i. Returns true in case it creates or finds instance. Also returns this instance as optional out variable.
{
	local MaterialInterface mat;
	if (comp != None && comp.GetNumElements() > 0 && i > -1 && i < comp.GetNumElements())
	{
		mat = comp.GetMaterial(i);
		CreatedInstance = ConditionalInitMaterialInstanceNoMesh(mat);
		if (CreatedInstance != None)
		{
			if (CreatedInstance != mat)
				comp.SetMaterial(i, CreatedInstance);
			return true;
		}
	}
	return false;
}

static function MaterialInstance ConditionalInitMaterialInstanceNoMesh(MaterialInterface mat) //Creates MaterialInstance (or returns detected one) and sets mat as its Parent. Does not set this Instance as material to MeshComponent.
{
	local MaterialInstance inst;
	if (mat == None)
		return None;
	if (MaterialInstance(mat) != None)
	{
		if (MaterialInstance(mat).IsInMapOrTransientPackage())
			return MaterialInstance(mat);
		if (MaterialInstanceConstant(mat) != None)
		{
			inst = new(None) class'MaterialInstanceConstant';
			inst.SetParent(mat);
			return inst;
		}
		else if (MaterialInstanceTimeVarying(mat) != None)
		{
			inst = new(None) class'MaterialInstanceTimeVarying';
			inst.SetParent(mat);
			return inst;
		}
	}
	else
	{
		inst = new(None) class'MaterialInstanceTimeVarying';
		inst.SetParent(mat);
		return inst;
	}
	return None;
}

static function MaterialInterface GetActualMaterial(MaterialInterface mat) //Returns actual (Editor-created) MaterialInterface.
{
	local MaterialInstance inst;
	inst = MaterialInstance(mat);
	if (inst == None)
		return mat;
	if (inst.IsInMapOrTransientPackage())
		return GetActualMaterial(inst.Parent);
	return inst;
}

static function bool SetMaterialParentToInstance(MeshComponent comp, int i, MaterialInterface NewParent) //Sets MaterialInstance Parent or SetMaterial+InitMaterialInstance. True if the material instance currently on the comp is transient and we can just change its parent. False otherwise.
{
	local MaterialInstance inst;
	local MaterialInterface mat;
	if (NewParent != None && comp != None && comp.GetNumElements() > 0 && comp.GetNumElements() > i)
	{
		inst = MaterialInstance(comp.GetMaterial(i));
		if (inst != None && inst.IsInMapOrTransientPackage())
		{
			if (inst.Parent != NewParent);
				inst.SetParent(NewParent);
			if (MaterialInstance(NewParent) != None && MaterialInstance(NewParent).IsInMapOrTransientPackage()) //What if we set transient MaterialInstance as parent? Might change parent to original material after instance's changes are applied.
			{
				mat = GetActualMaterial(NewParent);
				if (mat != None)
					inst.SetParent(mat);
			}
			return true;
		}
		else
		{
			comp.SetMaterial(i, NewParent);
			mat = NewParent.GetMaterial();
			if (mat != Material'HatInTime_Characters.Materials.Invisible' && mat != Material'HatInTime_Characters.Materials.OccludedMaterial')
				ConditionalInitMaterialInstance(comp, i);
			return false;
		}
	}
	return false;
}

static function class<Hat_Collectible_Skin> GetCurrentSkin(Actor a) //Returns current Skin used by player.
{
	local Hat_Loadout l;
	local Hat_GhostPartyPlayer gpp;
	local class<Hat_Collectible_Skin> SkinClass;
	if (a == None)
		return None;
	l = GetLoadout(a);
	if (l != None)
	{
		if (l.MyLoadout.Skin == None)
			return class'Hat_Collectible_Skin';
		SkinClass = class<Hat_Collectible_Skin>(l.MyLoadout.Skin.BackpackClass);
		return (SkinClass == None ? class'Hat_Collectible_Skin' : SkinClass);
	}
	gpp = Hat_GhostPartyPlayer(a);
	if (gpp == None)
		return None;
	return (gpp.CurrentSkin == None ? class'Hat_Collectible_Skin' : gpp.CurrentSkin);
}

static function Hat_Loadout GetLoadout(Actor a) //Returns loadout of Player. Input can be Hat_Player or Hat_NPC_Player.
{
	local Hat_Player ply;
	local Hat_NPC_Player npc;
	local Hat_PlayerController hpc;
	local Hat_PlayerReplicationInfo HPRI;
	if (a == None)
		return None;
	ply = Hat_Player(a);
	if (ply != None)
	{
		hpc = Hat_PlayerController(class'Shara_SteamID_Tools_RPS'.static.GetPawnPlayerController(ply));
		if (hpc != None)
			return hpc.GetLoadout();
		HPRI = Hat_PlayerReplicationInfo(ply.PlayerReplicationInfo);
		if (HPRI != None)
			return HPRI.MyLoadout;
		return None;
	}
	npc = Hat_NPC_Player(a);
	if (npc != None)
		return npc.GetLoadout();
	return None;
}