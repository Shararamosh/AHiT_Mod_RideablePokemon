class Hat_HUDElementSubtitles_Advanced_RPS extends Hat_HUDElement;

struct LocalizationInfo
{
	var string SectionName, KeyName, PackageName;
	var string LocalizedText; //LocalizedText = Localize(SectionName, KeyName, PackageName) if all three are not empty.
};

struct KeywordLocalizationInfo
{
	var string Keyword;
	var LocalizationInfo KeywordLocalization;
};

var private transient LocalizationInfo LocalizedSubtitles;
var private transient Array<KeywordLocalizationInfo> LocalizedKeywords;
var private transient float TimeUntilClose, FadeIn;
var private transient Color SubtitlesColor;

event OnLanguageChange()
{
	LocalizeSubtitles();
	LocalizeKeywords();
}

final private simulated function LocalizeSubtitles()
{
	if (LocalizedSubtitles.SectionName != "" && LocalizedSubtitles.KeyName != "" && LocalizedSubtitles.PackageName != "")
		LocalizedSubtitles.LocalizedText = Localize(LocalizedSubtitles.SectionName, LocalizedSubtitles.KeyName, LocalizedSubtitles.PackageName);
}

final static function LocalizeGameButtonKeywords(PlayerController pc, bool full, out string s)
{
	local int i;
	local Hat_PlayerInput_Base inp;
	if (pc == None)
		return;
	inp = Hat_PlayerInput_Base(pc.PlayerInput);
	for (i = 0; i < class'Hat_BubbleTalker_Compiler'.default.Buttons.Length; i++)
		s = Repl(s, "[button:"$class'Hat_BubbleTalker_Compiler'.default.Buttons[i].Name$"]", inp != None ? inp.GetGamepadButtonName(class'Hat_BubbleTalker_Compiler'.default.Buttons[i].Bind, full) : string(class'Hat_BubbleTalker_Compiler'.default.Buttons[i].Name), false);
}

final private simulated function LocalizeKeywords()
{
	local int i;
	for (i = 0; i < LocalizedKeywords.Length; i++)
	{
		if (LocalizedKeywords[i].KeywordLocalization.SectionName != "" && LocalizedKeywords[i].KeywordLocalization.KeyName != "" && LocalizedKeywords[i].KeywordLocalization.PackageName != "")
			LocalizedKeywords[i].KeywordLocalization.LocalizedText = Localize(LocalizedKeywords[i].KeywordLocalization.SectionName, LocalizedKeywords[i].KeywordLocalization.KeyName, LocalizedKeywords[i].KeywordLocalization.PackageName);
	}
}

final simulated function SetTimeUntilClose(float f)
{
	TimeUntilClose = f;
}

final simulated function SetKeywordReplacements(Array<KeywordLocalizationInfo> KeywordReplacements)
{
	LocalizedKeywords = KeywordReplacements;
	LocalizeKeywords();
}

function bool OnPreCloseHUD(HUD H)
{
	if (FClamp(FadeIn, 0.0, 1.0) == 0.0 && TimeUntilClose == 0.0)
		return false;
	TimeUntilClose = 0.0;
	return true;
}

function OnOpenHUD(HUD H, optional String command)
{
	FadeIn = FClamp(default.FadeIn, 0.0, 1.0);
	TimeUntilClose = default.TimeUntilClose;
	SubtitlesColor = default.SubtitlesColor;
	LocalizedSubtitles.LocalizedText = GetLocalizedSubtitleText(command, SubtitlesColor, LocalizedSubtitles.SectionName, LocalizedSubtitles.KeyName, LocalizedSubtitles.PackageName);
}

final static function string GetLocalizedSubtitleText(string SubtitleText, optional out Color SubtitleColor, optional out string SectionName, optional out string KeyName, optional out string PackageName)
{
	local int i;
	local Array<string> StringArray;
	SectionName = "";
	KeyName = "";
	PackageName = "";
	StringArray = SplitString(SubtitleText, "|", false);
	if (StringArray.Length >= 4) //At least 4 sections. 3 of them - color.
	{
		if (IsCorrectByte(StringArray[0]) && IsCorrectByte(StringArray[1]) && IsCorrectByte(StringArray[2]))
			SubtitleColor = MakeColor(int(StringArray[0]), int(StringArray[1]), int(StringArray[2]), 255);
		else
			return SubtitleText; //Failed to parse colors.
		if (StringArray.Length > 6) //More than 6 sections - removing color sections and merging everything together.
		{
			SubtitleText = StringArray[3];
			for (i = 4; i < StringArray.Length; i++)
				SubtitleText $= "|"$StringArray[i];
			return SubtitleText;
		}
		if (StringArray.Length == 6 && StringArray[3] != "" && StringArray[4] != "" && StringArray[5] != "") //Exactly 6 sections. First 3 - color, next 3 - localization info.
		{
			SectionName = StringArray[3];
			KeyName = StringArray[4];
			PackageName = StringArray[5];
			return Localize(SectionName, KeyName, PackageName);
		}
		else //4 or 5 sections - everything after 3rd section is part of localized text.
		{
			SubtitleText = StringArray[3];
			if (StringArray.Length == 5)
				SubtitleText $= "|"$StringArray[4];
			return SubtitleText;
		}
	}
	else if (StringArray.Length == 3 && StringArray[0] != "" && StringArray[1] != "" && StringArray[2] != "") //Only 3 sections - localization info without color.
	{
		SectionName = StringArray[0];
		KeyName = StringArray[1];
		PackageName = StringArray[2];
		return Localize(SectionName, KeyName, PackageName);
	}
	else //Less than 3 sections - whole string is a localized text.
		return SubtitleText;
}

final private simulated function string ApplyKeywordReplacements()
{
	local int i;
	local string EditedText;
	if (LocalizedSubtitles.LocalizedText == "")
		return "";
	EditedText = LocalizedSubtitles.LocalizedText;
	for (i = 0; i < LocalizedKeywords.Length; i++)
	{
		if (LocalizedKeywords[i].Keyword != "")
			EditedText = Repl(EditedText, "["$LocalizedKeywords[i].Keyword$"]", LocalizedKeywords[i].KeywordLocalization.LocalizedText);
	}
	return EditedText;
}

function bool Tick(HUD H, float d)
{
	if (!Super.Tick(H, d))
		return false;
	FadeIn = FClamp(FadeIn, 0.0, 1.0);
	if (TimeUntilClose == 0.0) //Subtitles are fading out - counting down FadeIn until 0.0.
	{
		FadeIn = FClamp(FadeIn-5.0*d, 0.0, 1.0);
		if (FadeIn == 0.0)
		{
			CloseHUD(H, Class, true);
			return false;
		}
	}
	else
	{
		if (FadeIn != 1.0) //Subtitles are not fully faded in yet - counting up FadeIn until 1.0.
			FadeIn = FClamp(FadeIn+5.0*d, 0.0, 1.0);
		else if (TimeUntilClose > 0.0) //Subtitles are fully faded in - counting down TimeUntilClose until 0.0 if it's not negative.
			TimeUntilClose = FMax(0.0, TimeUntilClose-d);
	}
	return true;
}

function bool Render(HUD H)
{
	local string ReplacedText;
    if (!Super.Render(H))
		return false;
	if (H == None || H.Canvas == None)
		return true;
	ReplacedText = ApplyKeywordReplacements();
	LocalizeGameButtonKeywords(H.PlayerOwner, false, ReplacedText);
	if (ReplacedText == "")
		return true;
	H.Canvas.SetDrawColor(SubtitlesColor.R, SubtitlesColor.G, SubtitlesColor.B, SubtitlesColor.A*FClamp(FadeIn, 0.0, 1.0));
	H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(ReplacedText);
	DrawBorderedText(H.Canvas, ReplacedText, H.Canvas.ClipX*0.5, H.Canvas.ClipY*0.88, H.Canvas.ClipX*0.00035, true, TextAlign_Center);
    return true;
}

final static function bool IsCorrectByte(string s) //Checks if the length is exactly 3 symbols and each symbol is a 0-9 number and at the end they form number from 0 to 255.
{
	if (Len(s) < 1)
		return false;
	if (!IsStringNumber(s))
		return false;
	if (int(s) > 255)
		return false;
	return true;
}

final static function bool IsCharNumber(string s) //Is this exactly a 0-9 number?
{
	switch(s)
	{
		case "0":
		case "1":
		case "2":
		case "3":
		case "4":
		case "5":
		case "6":
		case "7":
		case "8":
		case "9":
			return true;
		default:
			return false;
	}
}

final static function bool IsStringNumber(string s) //Is whole string a number?
{
	local int i;
	local string StringLetter;
	for (i = 0; i < Len(s); i++)
	{
		StringLetter = Mid(s, i, 1);
		if (IsCharNumber(StringLetter))
			continue;
		return false;
	}
	return true;
}

final static function LocalizationInfo MakeLocalizationInfo(optional string SectionName, optional string KeyName, optional string PackageName, optional string LocalizedText)
{
	local LocalizationInfo li;
	if (SectionName != "" && KeyName != "" && PackageName != "")
	{
		li.SectionName = SectionName;
		li.KeyName = KeyName;
		li.PackageName = PackageName;
	}
	else
		li.LocalizedText = LocalizedText;
	return li;
}

final static function KeywordLocalizationInfo MakeKeywordLocalizationInfo(string Keyword, LocalizationInfo li)
{
	local KeywordLocalizationInfo kli;
	if (Keyword != "")
	{
		kli.Keyword = Keyword;
		kli.KeywordLocalization = li;
	}
	return kli;
}

defaultproperties
{
	TimeUntilClose = 5.0
	SubtitlesColor = (R = 255, G = 255, B = 255, A = 255)
}