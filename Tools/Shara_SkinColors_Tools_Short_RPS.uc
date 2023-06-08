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

static function ConditionalInitMaterialInstancesMesh(MeshComponent comp) //Inits MaterialInstances on MeshComponent. Optimized: ConditionalInitMaterialInstance does not create unnecessary instances.
{
	local int i;
	if (comp == None)
		return;
	for (i = 0; i < comp.GetNumElements(); i++)
		ConditionalInitMaterialInstance(comp, i);
}

static function bool ConditionalInitMaterialInstance(MeshComponent comp, int i, optional out MaterialInstance CreatedInstance) //Inits one MaterialInstance on comp's Material with index i. Returns true in case it creates or finds instance. Also returns this instance as optional out variable. Force removes Invisible and OccludedMaterial instances.
{
	local MaterialInterface mat;
	CreatedInstance = None;
	if (i < 0)
		return false;
	if (comp == None)
		return false;
	mat = comp.GetMaterial(i);
	if (mat == None)
		return false;
	CreatedInstance = MaterialInstance(mat);
	if (CreatedInstance != None && CreatedInstance.IsInMapOrTransientPackage()) //The target Material is already a transient instance.
	{
		switch(mat.GetMaterial()) //Not creating instances of Invisible and OccludedMaterial.
		{
			case Material'HatInTime_Characters.Materials.Invisible':
			case Material'HatInTime_Characters.Materials.OccludedMaterial':
				comp.SetMaterial(i, GetActualMaterial(mat));
				CreatedInstance = None;
				return false;
			default:
				return true;
		}
	}
	switch(mat.GetMaterial())
	{
		case Material'HatInTime_Characters.Materials.Invisible':
		case Material'HatInTime_Characters.Materials.OccludedMaterial':
			CreatedInstance = None;
			return false;
		default:
			break;
	}
	if (MaterialInstanceConstant(mat) != None)
		CreatedInstance = comp.CreateAndSetMaterialInstanceConstant(i);
	else
		CreatedInstance = comp.CreateAndSetMaterialInstanceTimeVarying(i);
	return (CreatedInstance != None);
}

static function MaterialInstance ConditionalInitMaterialInstanceNoMesh(MaterialInterface mat) //Creates MaterialInstance (or returns detected one) and sets mat as its Parent. Does not set this Instance as Material to MeshComponent and does not ignore Invisible and OccludedMaterial.
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

static function bool SetMaterialParentToInstance(MeshComponent comp, int i, MaterialInterface NewParent) //Sets MaterialInstance Parent or SetMaterial+InitMaterialInstance. True if the Material Instance currently on the comp is transient and we can just change its parent. False otherwise.
{
	local MaterialInstance inst;
	local MaterialInterface mat;
	if (i < 0 || NewParent == None || comp == None)
		return false;
	inst = MaterialInstance(comp.GetMaterial(i));
	if (inst != None && inst.IsInMapOrTransientPackage())
	{
		switch(NewParent.GetMaterial()) //Force removing transient MaterialInstance of Invisible and OccludedMaterial.
		{
			case Material'HatInTime_Characters.Materials.Invisible':
			case Material'HatInTime_Characters.Materials.OccludedMaterial':
				comp.SetMaterial(i, GetActualMaterial(NewParent));
				return false;
		}
		if (inst.Parent != NewParent);
			inst.SetParent(NewParent);
		mat = GetActualMaterial(NewParent);
		if (mat != NewParent) //What if we set transient MaterialInstance as Parent? Might change Parent to original MaterialInterface after instance's changes are applied.
			inst.SetParent(mat);
		return true;
	}
	else
	{
		switch(NewParent.GetMaterial()) //Force removing transient MaterialInstance of Invisible and OccludedMaterial.
		{
			case Material'HatInTime_Characters.Materials.Invisible':
			case Material'HatInTime_Characters.Materials.OccludedMaterial':
				comp.SetMaterial(i, GetActualMaterial(NewParent));
				break;
			default:
				comp.SetMaterial(i, NewParent);
				ConditionalInitMaterialInstance(comp, i);
				break;
		}
		return false;
	}
}

static function class<Hat_Collectible_Skin> GetCurrentSkin(Actor a) //Returns current SkinClass used by Player.
{
	local Hat_Loadout l;
	local Hat_GhostPartyPlayer gpp;
	if (a == None)
		return None;
	l = GetLoadout(a);
	if (l != None)
		return GetSkinFromLoadout(l);
	gpp = Hat_GhostPartyPlayer(a);
	if (gpp == None)
		return None;
	return (gpp.CurrentSkin == None ? class'Hat_Collectible_Skin' : gpp.CurrentSkin);
}

static function class<Hat_Collectible_Skin> GetSkinFromLoadout(Hat_Loadout l) //Reads SkinClass from Hat_Loadout.
{
	local class<Hat_Collectible_Skin> SkinClass;
	if (l == None)
		return None;
	if (l.MyLoadout.Skin == None)
		return class'Hat_Collectible_Skin';
	SkinClass = class<Hat_Collectible_Skin>(l.MyLoadout.Skin.BackpackClass);
	return (SkinClass == None ? class'Hat_Collectible_Skin' : SkinClass);
}

static function Hat_Loadout GetLoadout(Actor a) //Returns loadout of Player. Input can be Pawn, Hat_PlayerController or Hat_NPC_Player.
{
	local Hat_PlayerController hpc;
	local Hat_NPC_Player npc;
	npc = Hat_NPC_Player(a);
	if (npc != None)
		return npc.GetLoadout();
	hpc = Hat_PlayerController(class'Shara_SteamID_Tools_RPS'.static.GetPlayerController(a));
	if (hpc == None)
		return None;
	return hpc.GetLoadout();
}