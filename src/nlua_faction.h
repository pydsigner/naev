/*
 * See Licensing and Copyright notice in naev.h
 */


#ifndef NLUA_FACTION_H
#  define NLUA_FACTION_H


#include "lua.h"


#define FACTION_METATABLE  "Faction" /**< Faction metatable identifier. */


/**
 * @brief Lua wrapper for a faction.
 */
typedef struct LuaFaction_s {
   int f; /**< Internal use faction identifier. */
} LuaFaction;


/* 
 * Load the space library.
 */
int lua_loadFaction( lua_State *L, int readonly );

/*
 * Faction operations
 */
LuaFaction* lua_tofaction( lua_State *L, int ind );
LuaFaction* lua_pushfaction( lua_State *L, LuaFaction faction );
int lua_isfaction( lua_State *L, int ind );


#endif /* NLUA_FACTION_H */


