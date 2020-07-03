#include <effectcalc>
#include <sdkhooks>

const float boost = 0.3 // +30%

int effect = -1

int offs_LaggedMovementValue

public void OnPluginStart()
{
	offs_LaggedMovementValue = FindSendPropInfo("CBasePlayer", "m_flLaggedMovementValue")
	if(offs_LaggedMovementValue)
	{
		SetFailState("Cant find \"m_flLaggedMovementValue\" prop")
		return
	}
	
	if(LibraryExists("effetcalc"))
	{
		ECalc_Hook("speed", "base", ModifySpeed)
		effect = ECalc_GetEffect("speed")
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if(!strcmp(name, "effectcalc"))
		effect = -1
}

public void OnLibraryAdded(const char[] name)
{
	if(!strcmp(name, "effectcalc"))
	{
		ECalc_Hook("speed", "base", ModifySpeed)
		effect = ECalc_GetEffect("speed")
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponSwitchPost, WeaponSwitchPost)
}

public void WeaponSwitchPost(int client, int args)
{
	static int temp[1]
	
	if(effect == -1)
		return
	
	temp[0] = client
	SetEntDataFloat(client, offs_LaggedMovementValue, ECalc_Run(effect, temp, 1))
}

public void ModifySpeed(any[] data, int size, float &value)
{
	if(size && 0 < data[0] <= MaxClients)
	{
		int weapon = GetEntPropEnt(data[0], Prop_Send, "m_hActiveWeapon")
		if(weapon == -1)
			return
		char sBuffer[8]
		GetEntityNetClass(weapon, sBuffer, sizeof sBuffer)
		if(!strncmp(sBuffer, "CKnife", 6))
			value += boost
	}
}