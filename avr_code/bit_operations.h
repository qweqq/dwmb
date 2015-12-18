#pragma once

#define bit(x) (1 << (x))
#define setbits(x,y) ((x) |= (y))
#define clearbits(x,y) ((x) &= (~(y)))
#define setbit(x,y) setbits((x), (bit((y))))
#define clearbit(x,y) clearbits((x), (bit((y))))
#define bitset(x,y) ((x) & (bit(y)))
#define bitclear(x,y) !bitset((x), (y))
#define bitsset(x,y) (((x) & (y)) == (y))
#define bitsclear(x,y) (((x) & (y)) == 0)
#define bitval(x,y) (((x)>>(y)) & 1)

#define setbitval(x,y,v) if ((v)) { setbit((x),(y)); } else { clearbit((x),(y)); }
