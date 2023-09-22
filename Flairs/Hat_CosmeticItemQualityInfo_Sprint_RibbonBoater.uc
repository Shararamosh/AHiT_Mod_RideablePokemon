class Hat_CosmeticItemQualityInfo_Sprint_RibbonBoater extends Hat_CosmeticItemQualityInfo_Sprint_RideablePokemon;

defaultproperties
{
	ItemQuality = class'Hat_ItemQuality_Rare'
	SupportsRoulette = true
	MeshOverride = SkeletalMesh'RideableQuagsire_Package.models.RibbonBoater'
	PhysicsAssetOverride = PhysicsAsset'RideableQuagsire_Package.Physics.RibbonBoater_Physics'
	bHasPhysicsAssetInstance = CIQ_On
	HUDIcon = Texture2D'RideableQuagsire_Package.Icons.RibbonBoater_Icon'
	SocketName = "KidHat"
	HidePonytail = CIQ_On
	HideFrontHair = CIQ_Off
	CosmeticItemName = "RibbonBoaterName"
	Description(0) = "RibbonBoaterDesc0"
	HatSectionGroup = "KidHat"
	StatusEffectOverride = class'Hat_StatusEffect_RideableQuagsire_M'
}