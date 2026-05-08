// Guardian Points + Profile screens

function GuardianScreen() {
  return (
    <div style={{
      width: '100%', height: '100%', background: JW.white,
      display: 'flex', flexDirection: 'column', overflow: 'auto',
    }}>
      {/* Top app bar */}
      <div style={{
        height: 56, display: 'flex', alignItems: 'center', padding: '0 16px',
        background: JW.white, position: 'relative',
      }}>
        <button style={{
          width: 44, height: 44, border: 'none', background: 'transparent', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <svg width="10" height="18" viewBox="0 0 10 18" fill="none">
            <path d="M9 1L1 9l8 8" stroke={JW.black} strokeWidth="2" strokeLinecap="round"/>
          </svg>
        </button>
        <div style={{
          flex: 1, textAlign: 'center', marginRight: 44,
          fontFamily: JW.font, fontWeight: 700, fontSize: 17,
        }}>Route Guardian</div>
      </div>

      {/* Black hero */}
      <div style={{
        background: JW.black, padding: '24px 20px 28px',
        position: 'relative', overflow: 'hidden',
      }}>
        {/* bg glyph */}
        <div style={{
          position: 'absolute', right: -20, top: -10, opacity: 0.05,
        }}>
          <JeepneyGlyph size={180} color={JW.white}/>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 14, position: 'relative' }}>
          <div style={{
            width: 56, height: 56, borderRadius: 999, background: JW.yellow,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 0 30px rgba(245,196,0,0.4)',
          }}>
            <JWShield size={28} color={JW.black}/>
          </div>
          <div>
            <div style={{
              fontFamily: JW.font, fontWeight: 500, fontSize: 13, color: JW.muted, letterSpacing: 0.5,
            }}>SILVER GUARDIAN</div>
            <div style={{
              fontFamily: JW.font, fontWeight: 700, fontSize: 36,
              color: JW.yellow, letterSpacing: -0.5, lineHeight: 1.1,
            }}>1,240<span style={{ fontSize: 16, color: JW.muted, marginLeft: 6 }}>pts</span></div>
          </div>
        </div>
        <div style={{ height: 14 }}/>
        <div style={{
          background: 'rgba(255,255,255,0.08)', borderRadius: 10,
          padding: '10px 12px', display: 'flex', alignItems: 'center', gap: 10,
        }}>
          <div style={{
            fontFamily: JW.font, fontSize: 12, color: JW.white, flex: 1,
          }}>260 pts to <b style={{ color: JW.yellow }}>Gold Guardian</b></div>
        </div>
      </div>

      {/* Content */}
      <div style={{ padding: '20px 20px 24px' }}>
        <div style={{
          fontFamily: JW.font, fontWeight: 700, fontSize: 16, marginBottom: 12,
        }}>Iyong mga Ruta</div>

        {[
          { code: 'EDSA C-Q', name: 'EDSA Cubao–Quiapo', reports: 28, progress: 0.74 },
          { code: 'Colon-SM', name: 'Colon to SM Cebu', reports: 12, progress: 0.31 },
        ].map((r, i) => (
          <div key={i} style={{
            background: JW.white, borderRadius: 12, border: `1px solid ${JW.chip}`,
            padding: 14, marginBottom: 10,
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <div style={{
                background: JW.black, color: JW.white, padding: '4px 9px',
                borderRadius: 999, fontFamily: JW.font, fontWeight: 700, fontSize: 11,
              }}>{r.code}</div>
              <div style={{ flex: 1, fontFamily: JW.font, fontWeight: 500, fontSize: 14 }}>{r.name}</div>
              <div style={{ fontFamily: JW.font, fontSize: 12, color: JW.body }}>{r.reports} reports</div>
            </div>
            <div style={{ height: 10 }}/>
            <div style={{ height: 6, background: JW.chip, borderRadius: 999, overflow: 'hidden' }}>
              <div style={{ width: `${r.progress*100}%`, height: '100%', background: JW.yellow, borderRadius: 999 }}/>
            </div>
          </div>
        ))}

        <div style={{ height: 24 }}/>
        <div style={{
          fontFamily: JW.font, fontWeight: 700, fontSize: 16, marginBottom: 4,
        }}>Leaderboard</div>
        <div style={{
          fontFamily: JW.font, fontSize: 12, color: JW.body, marginBottom: 12,
        }}>EDSA Cubao–Quiapo · ngayong linggo</div>

        {[
          { rank: 1, name: 'Ate Marisol', pts: 4820, gold: true },
          { rank: 2, name: 'KuyaBudoy', pts: 3210 },
          { rank: 3, name: 'JeepneyJoyce', pts: 2104 },
          { rank: 7, name: 'Ikaw (JR)', pts: 1240, you: true },
        ].map((u, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 12,
            padding: '12px 14px', borderRadius: 10,
            background: u.you ? JW.chip : 'transparent',
            borderLeft: u.gold ? `3px solid ${JW.yellow}` : '3px solid transparent',
            marginBottom: 4,
          }}>
            <div style={{
              width: 24, fontFamily: JW.font, fontWeight: 700, fontSize: 14,
              color: u.gold ? JW.yellowDark : JW.body,
            }}>{u.rank}</div>
            <div style={{
              width: 32, height: 32, borderRadius: 999, background: JW.black,
              color: JW.white, display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontFamily: JW.font, fontWeight: 700, fontSize: 11,
            }}>{u.name[0]}</div>
            <div style={{ flex: 1, fontFamily: JW.font, fontWeight: u.you ? 700 : 500, fontSize: 14 }}>{u.name}</div>
            <div style={{ fontFamily: JW.font, fontWeight: 700, fontSize: 14 }}>{u.pts.toLocaleString()}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function ProfileScreen() {
  return (
    <div style={{
      width: '100%', height: '100%', background: '#F7F5EF',
      overflow: 'auto', display: 'flex', flexDirection: 'column',
    }}>
      <div style={{
        height: 56, display: 'flex', alignItems: 'center', justifyContent: 'center',
        background: '#F7F5EF',
        fontFamily: JW.font, fontWeight: 700, fontSize: 17,
      }}>Profile</div>

      <div style={{ padding: '12px 16px 24px' }}>
        {/* Profile card */}
        <div style={{
          background: JW.white, borderRadius: 14, padding: 18,
          display: 'flex', alignItems: 'center', gap: 14, boxShadow: JW.shadowLight,
        }}>
          <div style={{
            width: 56, height: 56, borderRadius: 999, background: JW.black,
            color: JW.white, display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: JW.font, fontWeight: 700, fontSize: 20,
          }}>JR</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: JW.font, fontWeight: 700, fontSize: 17 }}>Juan Reyes</div>
            <div style={{ fontFamily: JW.font, fontSize: 13, color: JW.body, marginTop: 2 }}>+63 917 555 4231</div>
            <div style={{
              display: 'inline-flex', alignItems: 'center', gap: 5, marginTop: 6,
              background: JW.yellow, padding: '3px 8px 3px 6px', borderRadius: 999,
            }}>
              <JWShield size={11} color={JW.black}/>
              <span style={{ fontFamily: JW.font, fontWeight: 700, fontSize: 10, color: JW.black }}>SILVER GUARDIAN</span>
            </div>
          </div>
        </div>

        <div style={{ height: 20 }}/>
        {[
          { header: 'APP', items: ['Notifications', 'GPS Accuracy Mode', 'Wika · Filipino'] },
          { header: 'ACCOUNT', items: ['Saved Routes', 'Privacy', 'Terms of Service'] },
          { header: 'ABOUT', items: ['App Version · 1.0.4', 'Report a Bug', 'Rate the App'] },
        ].map(sec => (
          <div key={sec.header}>
            <div style={{
              fontFamily: JW.font, fontWeight: 700, fontSize: 11, color: JW.muted,
              letterSpacing: 0.7, padding: '6px 6px 6px',
            }}>{sec.header}</div>
            <div style={{
              background: JW.white, borderRadius: 14, marginBottom: 16, overflow: 'hidden',
            }}>
              {sec.items.map((item, i) => (
                <div key={i} style={{
                  display: 'flex', alignItems: 'center',
                  padding: '14px 16px', minHeight: 52,
                  borderBottom: i < sec.items.length - 1 ? `1px solid ${JW.chip}` : 'none',
                  fontFamily: JW.font, fontSize: 15,
                }}>
                  <div style={{ flex: 1 }}>{item}</div>
                  <svg width="7" height="12" viewBox="0 0 8 14">
                    <path d="M1 1l6 6-6 6" stroke={JW.muted} strokeWidth="1.7" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
                  </svg>
                </div>
              ))}
            </div>
          </div>
        ))}

        <div style={{ height: 8 }}/>
        <JWPill bg={JW.white} color={JW.black} fullWidth border={`1px solid ${JW.black}`}>
          Mag-sign out
        </JWPill>
      </div>
    </div>
  );
}

Object.assign(window, { GuardianScreen, ProfileScreen });
