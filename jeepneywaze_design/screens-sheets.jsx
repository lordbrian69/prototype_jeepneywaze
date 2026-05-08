// Route detail, stop detail, crowd report sheets

function RouteDetailSheet() {
  const vehicles = [
    { eta: '2', crowd: 'siksikan', stops: 1, plate: 'NHJ-4421' },
    { eta: '6', crowd: 'malwag', stops: 3, plate: 'NHJ-2810' },
    { eta: '11', crowd: 'katamtaman', stops: 5, plate: 'NHJ-9054' },
    { eta: '17', crowd: 'malwag', stops: 8, plate: 'NHJ-1633' },
  ];
  return (
    <div style={{
      width: '100%', height: '100%', background: JW.white,
      borderRadius: '20px 20px 0 0', display: 'flex', flexDirection: 'column',
      overflow: 'hidden',
    }}>
      <DragHandle />
      <div style={{
        display: 'flex', alignItems: 'center', gap: 10,
        padding: '4px 20px 14px', borderBottom: `1px solid ${JW.chip}`,
      }}>
        <div style={{
          background: JW.black, color: JW.white, padding: '5px 10px',
          borderRadius: 999, fontFamily: JW.font, fontWeight: 700, fontSize: 12,
        }}>EDSA C-Q</div>
        <div style={{ flex: 1 }}>
          <div style={{ fontFamily: JW.font, fontWeight: 700, fontSize: 17 }}>EDSA Cubao–Quiapo</div>
          <div style={{ fontFamily: JW.font, fontSize: 12, color: JW.body }}>via Aurora Blvd · 14.2 km</div>
        </div>
        <button style={{
          width: 36, height: 36, border: 'none', background: 'transparent', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
            <path d="M11 19 C 4 14, 1 10, 1 7 a4.5 4.5 0 0 1 9-1.5 a4.5 4.5 0 0 1 9 1.5 c 0 3 -3 7 -10 12z"
                  fill={JW.yellow} stroke={JW.black} strokeWidth="1.6"/>
          </svg>
        </button>
      </div>

      <div style={{
        padding: '14px 20px 8px',
        fontFamily: JW.font, fontWeight: 700, fontSize: 11,
        color: JW.muted, letterSpacing: 0.7,
      }}>LIVE NA SASAKYAN</div>

      <div style={{ flex: 1, overflow: 'auto', padding: '0 20px 8px' }}>
        {vehicles.map((v, i) => {
          const accent = v.crowd === 'malwag' ? JW.green : v.crowd === 'siksikan' ? JW.red : JW.orange;
          return (
            <div key={i} style={{
              background: JW.white, borderRadius: 12,
              border: `1px solid ${JW.chip}`,
              padding: '12px 14px', marginBottom: 10,
              display: 'flex', alignItems: 'center', gap: 12,
              position: 'relative', overflow: 'hidden',
            }}>
              <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: 4, background: accent }}/>
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', alignItems: 'baseline', gap: 5 }}>
                  <span style={{ fontFamily: JW.font, fontWeight: 700, fontSize: 28, lineHeight: 1 }}>{v.eta}</span>
                  <span style={{ fontFamily: JW.font, fontWeight: 500, fontSize: 13, color: JW.body }}>min</span>
                </div>
                <div style={{ fontFamily: JW.font, fontSize: 12, color: JW.body, marginTop: 4 }}>
                  {v.stops} stops · {v.plate}
                </div>
              </div>
              <JWBadge kind={v.crowd} />
              <svg width="8" height="14" viewBox="0 0 8 14">
                <path d="M1 1l6 6-6 6" stroke={JW.muted} strokeWidth="1.7" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </div>
          );
        })}
        <div style={{
          textAlign: 'center', padding: '6px 0 12px',
          fontFamily: JW.font, fontSize: 12, color: JW.muted,
          textDecoration: 'underline',
        }}>May problema sa data?</div>
      </div>

      <div style={{ padding: '12px 20px 16px', borderTop: `1px solid ${JW.chip}` }}>
        <JWPill bg={JW.yellow} color={JW.black} weight={700} fullWidth>
          Nandito na ako
        </JWPill>
      </div>
    </div>
  );
}

function StopDetailSheet() {
  return (
    <div style={{
      width: '100%', height: '100%', background: JW.white,
      borderRadius: '20px 20px 0 0', display: 'flex', flexDirection: 'column',
    }}>
      <DragHandle />
      <div style={{ padding: '8px 20px 20px' }}>
        <div style={{ fontFamily: JW.font, fontWeight: 700, fontSize: 22, color: JW.black }}>
          Guadalupe MRT Station
        </div>
        <div style={{ fontFamily: JW.font, fontSize: 14, color: JW.body, marginTop: 2 }}>
          Kanto sa EDSA Southbound
        </div>

        <div style={{ height: 16, borderTop: `1px solid ${JW.chip}`, marginTop: 16 }}/>

        <div style={{
          fontFamily: JW.font, fontWeight: 700, fontSize: 11,
          color: JW.muted, letterSpacing: 0.7,
        }}>SUSUNOD NA JEEPNEY</div>

        <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, marginTop: 8 }}>
          <span style={{ fontFamily: JW.font, fontWeight: 700, fontSize: 48, lineHeight: 1, color: JW.black }}>3</span>
          <span style={{ fontFamily: JW.font, fontWeight: 500, fontSize: 18, color: JW.body }}>min</span>
          <div style={{ flex: 1 }}/>
          <JWBadge kind="malwag" />
        </div>
        <div style={{ fontFamily: JW.font, fontSize: 14, color: JW.body, marginTop: 6 }}>
          2 jeepney ang papalapit · EDSA C-Q
        </div>

        <div style={{ borderTop: `1px solid ${JW.chip}`, marginTop: 20, paddingTop: 16 }}>
          <button style={{
            width: '100%', display: 'flex', alignItems: 'center', gap: 12,
            background: 'transparent', border: 'none', padding: '12px 0', cursor: 'pointer',
          }}>
            <div style={{
              width: 36, height: 36, borderRadius: 10, background: JW.chip,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <JeepneyGlyph size={20} color={JW.black} />
            </div>
            <span style={{ flex: 1, textAlign: 'left', fontFamily: JW.font, fontWeight: 500, fontSize: 15 }}>
              Mag-report ng crowd
            </span>
            <svg width="8" height="14" viewBox="0 0 8 14">
              <path d="M1 1l6 6-6 6" stroke={JW.muted} strokeWidth="1.7" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </button>
        </div>

        <div style={{ height: 12 }}/>
        <JWPill fullWidth>I-notify ako</JWPill>
      </div>
    </div>
  );
}

function CrowdReportV1() {
  return (
    <div style={{
      width: '100%', height: '100%', background: JW.white,
      borderRadius: '20px 20px 0 0', display: 'flex', flexDirection: 'column',
    }}>
      <DragHandle />
      <div style={{ padding: '8px 20px 24px' }}>
        <div style={{ fontFamily: JW.font, fontWeight: 700, fontSize: 20, textAlign: 'center' }}>
          Kamusta ang sasakyan?
        </div>
        <div style={{ fontFamily: JW.font, fontSize: 14, color: JW.body, textAlign: 'center', marginTop: 6 }}>
          Para sa ibang commuters na naghihintay.
        </div>

        <div style={{ height: 24 }}/>

        {[
          { bg: JW.red, label: 'SIKSIKAN', sub: 'Puno na!' },
          { bg: JW.orange, label: 'KATAMTAMAN', sub: 'Pwede pa.' },
          { bg: JW.green, label: 'MALWAG', sub: 'May puwang pa!' },
        ].map(o => (
          <button key={o.label} style={{
            width: '100%', height: 60, marginBottom: 10,
            background: o.bg, color: JW.white, border: 'none',
            borderRadius: 999, fontFamily: JW.font, cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 12,
          }}>
            <JeepneyGlyph size={22} color={JW.white} />
            <div style={{ textAlign: 'left' }}>
              <div style={{ fontWeight: 700, fontSize: 16, lineHeight: 1.1 }}>{o.label}</div>
              <div style={{ fontWeight: 400, fontSize: 12, opacity: 0.9 }}>{o.sub}</div>
            </div>
          </button>
        ))}

        <div style={{
          textAlign: 'center', marginTop: 12,
          fontFamily: JW.font, fontSize: 13, color: JW.muted,
        }}>Hindi na ako makapag-report</div>
      </div>
    </div>
  );
}

function CrowdReportV2() {
  // visual variant: 3 large tiles, side by side, with iconographic crowd density
  return (
    <div style={{
      width: '100%', height: '100%', background: JW.white,
      borderRadius: '20px 20px 0 0', display: 'flex', flexDirection: 'column',
    }}>
      <DragHandle />
      <div style={{ padding: '8px 20px 24px' }}>
        <div style={{ fontFamily: JW.font, fontWeight: 700, fontSize: 22, textAlign: 'center' }}>
          Gaano kasiksik?
        </div>
        <div style={{ fontFamily: JW.font, fontSize: 13, color: JW.body, textAlign: 'center', marginTop: 4 }}>
          Tap to report · EDSA C-Q
        </div>

        <div style={{ height: 24 }}/>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10 }}>
          {[
            { bg: JW.green, label: 'MALWAG', filled: 1 },
            { bg: JW.orange, label: 'KATAMTAMAN', filled: 3 },
            { bg: JW.red, label: 'SIKSIKAN', filled: 5 },
          ].map(o => (
            <button key={o.label} style={{
              border: `2px solid ${JW.black}`, borderRadius: 16,
              background: JW.white, padding: '14px 8px 12px',
              cursor: 'pointer', display: 'flex', flexDirection: 'column',
              alignItems: 'center', gap: 8,
            }}>
              {/* density viz */}
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: 3, width: 56 }}>
                {[0,1,2,3,4].map(i => (
                  <div key={i} style={{
                    width: 8, height: 12, borderRadius: 1,
                    background: i < o.filled ? o.bg : JW.chip,
                  }}/>
                ))}
              </div>
              <div style={{
                background: o.bg, color: JW.white,
                fontFamily: JW.font, fontWeight: 700, fontSize: 10, letterSpacing: 0.5,
                padding: '4px 7px', borderRadius: 999,
              }}>{o.label}</div>
            </button>
          ))}
        </div>

        <div style={{ height: 18 }}/>

        <div style={{
          background: JW.chip, borderRadius: 12, padding: '12px 14px',
          display: 'flex', alignItems: 'center', gap: 10,
        }}>
          <div style={{
            width: 28, height: 28, borderRadius: 999, background: JW.yellow,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <JWShield size={16} color={JW.black}/>
          </div>
          <div style={{ flex: 1, fontFamily: JW.font, fontSize: 13, color: JW.body }}>
            Kumita ng <b style={{ color: JW.black }}>+5 Guardian Points</b> sa pag-report
          </div>
        </div>

        <div style={{ height: 14 }}/>
        <div style={{
          textAlign: 'center', fontFamily: JW.font, fontSize: 13, color: JW.muted,
        }}>I-skip muna</div>
      </div>
    </div>
  );
}

Object.assign(window, { RouteDetailSheet, StopDetailSheet, CrowdReportV1, CrowdReportV2 });
