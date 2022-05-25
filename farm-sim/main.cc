#include <stdio.h>
#include <unistd.h>

#include <cstdlib>

extern "C" {
#include "lauxlib.h"
#include "lua.h"
#include "lualib.h"
}

#ifdef __cplusplus
extern "C" {
#endif

static int transmitSpeed(lua_State* L) {
  int n = lua_gettop(L);
  double speed = lua_tonumber(L, 1);
  fprintf(stdout, "Speed: %f\n", speed);
  fflush(stdout);
  lua_pushnumber(L, speed);

  return 1;
}

// library to be registered
static const struct luaL_Reg windSimulatorUsb[] = {
    {"transmitSpeed", transmitSpeed}, {NULL, NULL}};

// name of this function is not flexible
int luaopen_windSimulatorUsb(lua_State* L) {
  luaL_newlib(L, windSimulatorUsb);
  return 1;
}

#ifdef __cplusplus
}
#endif
