// Home Map screen + variations + sheets

function HomeMapBase({ variant = 'default', tweaks = {}, onBeaconClick, selectedId, sheetState = 'peek' }) {
  const dark = tweaks.darkMap;
  const density = tweaks.density || 'normal';
  const crowdState = tweaks.crowdState || 'mixed';

  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: dark ? '#1a1a1a' : '#EFECE5', overflow: 'hidden',
    }}>
      <JWMap width={375} height={812} dark={dark}
             density={density} crowdState={crowdState}
             onBeaconClick={onBeaconClick} selectedId={selectedId}
             etas={{ b1: true, b3: true, b5: true }}/>

      {/* Top: search bar */}
      <div style={{
        position: 'absolute', top: 54, left: 16, right: 16,
        background: JW.white, borderRadius: 14, height: 52,
        boxShadow: JW.shadowLight,
        display: 'flex', alignItems: 'center', padding: '0 14px', gap: 12,
      }}>
        <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
          <circle cx="8" cy="8" r="6" stroke={JW.black} strokeWidth="2"/>
          <line x1="12.5" y1="12.5" x2="16" y2="16" stroke={JW.black} strokeWidth="2" strokeLinecap="round"/>
        </svg>
        <span style={{
          flex: 1, fontFamily: JW.font, fontWeight: 400, fontSize: 15, color: JW.muted,
        }}>Saan ka pupunta?</span>
        <div style={{
          width: 32, height: 32, borderRadius: 999,
          background: JW.black, color: JW.white,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: JW.font, fontWeight: 700, fontSize: 12,
        }}>JR</div>
      </div>

      {/* Filter chips */}
      <div style={{
        position: 'absolute', top: 120, left: 0, right: 0,
        display: 'flex', gap: 8, padding: '0 16px',
        overflowX: 'auto', WebkitOverflowScrolling: 'touch',
      }}>
        <JWChip active>Lahat</JWChip>
        <JWChip>EDSA Cubao–Quiapo</JWChip>
        <JWChip>Colon–SM</JWChip>
        <JWChip>+ Dagdag</JWChip>
      </div>

      {/* FABs */}
      <div style={{
        position: 'absolute', right: 16, bottom: 280,
        display: 'flex', flexDirection: 'column', gap: 12,
      }}>
        <FabButton>
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <rect x="2" y="2" width="7" height="7" stroke={JW.black} strokeWidth="1.6"/>
            <rect x="11" y="2" width="7" height="7" stroke={JW.black} strokeWidth="1.6"/>
            <rect x="2" y="11" width="7" height="7" stroke={JW.black} strokeWidth="1.6"/>
            <rect x="11" y="11" width="7" height="7" stroke={JW.black} strokeWidth="1.6"/>
          </svg>
        </FabButton>
        <FabButton>
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <circle cx="10" cy="10" r="3" fill={JW.black}/>
            <circle cx="10" cy="10" r="7" stroke={JW.black} strokeWidth="1.6"/>
            <line x1="10" y1="0" x2="10" y2="3" stroke={JW.black} strokeWidth="1.6"/>
            <line x1="10" y1="17" x2="10" y2="20" stroke={JW.black} strokeWidth="1.6"/>
            <line x1="0" y1="10" x2="3" y2="10" stroke={JW.black} strokeWidth="1.6"/>
            <line x1="17" y1="10" x2="20" y2="10" stroke={JW.black} strokeWidth="1.6"/>
          </svg>
        </FabButton>
      </div>

      {/* Bottom sheet */}
      {variant === 'cards' && <BottomSheetCards />}
      {variant === 'list' && <BottomSheetList />}
      {variant === 'minimal' && <BottomSheetMinimal />}
      {variant === 'default' && <BottomSheetCards />}

      {/* Bottom nav */}
      <BottomNav active="map" />
    </div>
  );
}

function FabButton({ children, onClick }) {
  return (
    <button onClick={onClick} style={{
      width: 48, height: 48, borderRadius: 999,
      background: JW.white, border: 'none',
      boxShadow: JW.shadowMed, cursor: 'pointer',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>{children}</button>
  );
}

function BottomNav({ active = 'map' }) {
  const items = [
    { id: 'map', label: 'Mapa', icon: <svg width="22" height="22" viewBox="0 0 22 22"><path d="M2 5 L8 3 L14 5 L20 3 V17 L14 19 L8 17 L2 19 Z M8 3 V17 M14 5 V19" fill="none" stroke="currentColor" strokeWidth="1.7"/></svg> },
    { id: 'routes', label: 'Ruta', icon: <svg width="22" height="22" viewBox="0 0 22 22"><circle cx="5" cy="5" r="2.5" fill="currentColor"/><circle cx="17" cy="17" r="2.5" fill="currentColor"/><path d="M5 8 V14 a3 3 0 0 0 3 3 H14" stroke="currentColor" strokeWidth="1.7" fill="none"/></svg> },
    { id: 'alerts', label: 'Alerto', icon: <svg width="22" height="22" viewBox="0 0 22 22"><path d="M11 3 a6 6 0 0 0-6 6 v4 l-2 3 h16 l-2-3 V9 a6 6 0 0 0-6-6 z" fill="none" stroke="currentColor" strokeWidth="1.7"/><path d="M9 18 a2 2 0 0 0 4 0" stroke="currentColor" strokeWidth="1.7" fill="none"/></svg> },
    { id: 'profile', label: 'Profile', icon: <svg width="22" height="22" viewBox="0 0 22 22"><circle cx="11" cy="8" r="4" fill="none" stroke="currentColor" strokeWidth="1.7"/><path d="M3 19 a8 6 0 0 1 16 0" fill="none" stroke="currentColor" strokeWidth="1.7"/></svg> },
  ];
  return (
    <div style={{
      position: 'absolute', bottom: 0, left: 0, right: 0,
      height: 76, paddingBottom: 14,
      background: JW.white, borderTop: `1px solid ${JW.chip}`,
      display: 'flex', zIndex: 20,
    }}>
      {items.map(it => {
        const isActive = it.id === active;
        return (
          <div key={it.id} style={{
            flex: 1, display: 'flex', flexDirection: 'column',
            alignItems: 'center', justifyContent: 'flex-start',
            paddingTop: 8, position: 'relative',
            color: isActive ? JW.black : JW.muted,
          }}>
            {isActive && (
              <div style={{
                position: 'absolute', top: 0, width: 20, height: 3,
                background: JW.yellow, borderRadius: 999,
              }}/>
            )}
            {it.icon}
            <div style={{
              fontFamily: JW.font, fontWeight: isActive ? 500 : 400, fontSize: 11,
              marginTop: 3,
            }}>{it.label}</div>
          </div>
        );
      })}
    </div>
  );
}

function DragHandle() {
  return (
    <div style={{ width: '100%', display: 'flex', justifyContent: 'center', padding: '10px 0 6px' }}>
      <div style={{ width: 36, height: 4, background: JW.chip, borderRadius: 999 }}/>
    </div>
  );
}

function MiniRouteCard({ code, eta, crowd, stops }) {
  const accent = crowd === 'malwag' ? JW.green : crowd === 'siksikan' ? JW.red : JW.orange;
  return (
    <div style={{
      flexShrink: 0, width: 220, background: JW.white, borderRadius: 12,
      border: `1px solid ${JW.chip}`,
      padding: 14, position: 'relative', overflow: 'hidden',
    }}>
      <div style={{
        position: 'absolute', left: 0, top: 0, bottom: 0, width: 4, background: accent,
      }}/>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
        <div style={{
          background: JW.black, color: JW.white, padding: '3px 8px',
          borderRadius: 999, fontFamily: JW.font, fontWeight: 700, fontSize: 11,
        }}>{code}</div>
        <JWBadge kind={crowd} />
      </div>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 6 }}>
        <span style={{ fontFamily: JW.font, fontWeight: 700, fontSize: 28, color: JW.black, lineHeight: 1 }}>{eta}</span>
        <span style={{ fontFamily: JW.font, fontWeight: 500, fontSize: 12, color: JW.body }}>min</span>
      </div>
      <div style={{ fontFamily: JW.font, fontSize: 12, color: JW.body, marginTop: 4 }}>{stops} stops away</div>
    </div>
  );
}

function BottomSheetCards() {
  return (
    <div style={{
      position: 'absolute', bottom: 76, left: 0, right: 0,
      background: JW.white, borderRadius: '20px 20px 0 0',
      boxShadow: 'rgba(0,0,0,0.16) 0px -4px 24px',
      paddingBottom: 16, zIndex: 10,
    }}>
      <DragHandle />
      <div style={{ padding: '4px 20px 12px' }}>
        <div style={{ fontFamily: JW.font, fontWeight: 700, fontSize: 16 }}>Mga Malapit na Jeepney</div>
        <div style={{ fontFamily: JW.font, fontSize: 12, color: JW.body, marginTop: 2 }}>5 sasakyan sa loob ng 500m</div>
      </div>
      <div style={{ display: 'flex', gap: 10, padding: '0 20px', overflowX: 'auto' }}>
        <MiniRouteCard code="EDSA C-Q" eta="2" crowd="siksikan" stops={1} />
        <MiniRouteCard code="EDSA C-Q" eta="6" crowd="malwag" stops={3} />
        <MiniRouteCard code="Colon-SM" eta="4" crowd="katamtaman" stops={2} />
      </div>
    </div>
  );
}

function BottomSheetList() {
  return (
    <div style={{
      position: 'absolute', bottom: 76, left: 0, right: 0,
      background: JW.white, borderRadius: '20px 20px 0 0',
      boxShadow: 'rgba(0,0,0,0.16) 0px -4px 24px',
      paddingBottom: 12, zIndex: 10,
    }}>
      <DragHandle />
      <div style={{ padding: '4px 20px 8px' }}>
        <div style={{ fontFamily: JW.font, fontWeight: 700, fontSize: 16 }}>Mga Malapit na Jeepney</div>
      </div>
      <div style={{ padding: '0 20px' }}>
        {[
          { code: 'EDSA C-Q', eta: '2', crowd: 'siksikan', stops: 1 },
          { code: 'Colon-SM', eta: '4', crowd: 'katamtaman', stops: 2 },
          { code: 'EDSA C-Q', eta: '6', crowd: 'malwag', stops: 3 },
        ].map((r, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 12,
            padding: '10px 0', borderBottom: i < 2 ? `1px solid ${JW.chip}` : 'none',
          }}>
            <div style={{
              background: JW.black, color: JW.white, padding: '4px 8px',
              borderRadius: 999, fontFamily: JW.font, fontWeight: 700, fontSize: 11, flexShrink: 0,
            }}>{r.code}</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: JW.font, fontWeight: 700, fontSize: 18 }}>{r.eta} min</div>
              <div style={{ fontFamily: JW.font, fontSize: 11, color: JW.body }}>{r.stops} stops</div>
            </div>
            <JWBadge kind={r.crowd} />
          </div>
        ))}
      </div>
    </div>
  );
}

function BottomSheetMinimal() {
  return (
    <div style={{
      position: 'absolute', bottom: 76, left: 16, right: 16,
      background: JW.white, borderRadius: 14,
      boxShadow: JW.shadowMed, marginBottom: 12,
      padding: '14px 16px', zIndex: 10,
      display: 'flex', alignItems: 'center', gap: 12,
    }}>
      <div style={{
        width: 38, height: 38, borderRadius: 10, background: JW.yellow,
        border: `2px solid ${JW.black}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <JeepneyGlyph size={22} color={JW.black} />
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 4 }}>
          <span style={{ fontFamily: JW.font, fontWeight: 700, fontSize: 22 }}>2</span>
          <span style={{ fontFamily: JW.font, fontWeight: 500, fontSize: 12, color: JW.body }}>min · EDSA C-Q</span>
        </div>
        <div style={{ fontFamily: JW.font, fontSize: 11, color: JW.body }}>papalapit sa Guadalupe MRT</div>
      </div>
      <JWBadge kind="siksikan" />
    </div>
  );
}

Object.assign(window, { HomeMapBase, BottomNav, DragHandle });
