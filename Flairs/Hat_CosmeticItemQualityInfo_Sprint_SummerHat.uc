class Hat_CosmeticItemQualityInfo_Sprint_SummerHat extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	ItemQuality = class'Hat_ItemQuality_Epic'
	SupportsRoulette = true
	MeshOverride = SkeletalMesh'RideableGarchomp_Package.models.Summer_Hat'
	PhysicsAssetOverride = PhysicsAsset'RideableGarchomp_Package.Physics.Summer_Hat_Physics'
	bHasPhysicsAssetInstance = CIQ_On
	HUDIcon = Texture2D'RideableGarchomp_Package.Icons.SummerHat_Icon'
	SocketName = "KidHat"
	HidePonytail = CIQ_Off
	HideFrontHair = CIQ_Off
	CosmeticItemName = "SummerHatName"
	Description(0) = "SummerHatDesc0"
	HatSectionGroup = "KidHat"
	StatusEffectOverride = class'Hat_StatusEffect_RideableGarchomp_M'
}