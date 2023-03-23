class Hat_CosmeticItemQualityInfo_Sprint_WoolKnit extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	ItemQuality = class'Hat_ItemQuality_Rare'
	SupportsRoulette = true
	MeshOverride = SkeletalMesh'RideableOctillery_Package.models.WoolKnit'
	PhysicsAssetOverride = PhysicsAsset'RideableOctillery_Package.Physics.WoolKnit_Physics'
	bHasPhysicsAssetInstance = CIQ_On
	HUDIcon = Texture2D'RideableOctillery_Package.Icons.WoolKnit_Icon'
	SocketName = "KidHat"
	HidePonytail = CIQ_On
	HideFrontHair = CIQ_Off
	CosmeticItemName = "WoolKnitName"
	Description(0) = "WoolKnitDesc0"
	HatSectionGroup = "KidHat"
	StatusEffectOverride = class'Hat_StatusEffect_RideableOctillery_M'
}