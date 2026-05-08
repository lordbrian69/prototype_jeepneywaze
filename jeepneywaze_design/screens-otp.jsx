// OTP screens

function OtpEntry() {
  return (
    <div style={{
      width: '100%', height: '100%', background: JW.white,
      display: 'flex', flexDirection: 'column',
    }}>
      {/* Top bar */}
      <div style={{
        height: 56, display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontFamily: JW.font, fontWeight: 700, fontSize: 17, color: JW.black,
        borderBottom: `1px solid ${JW.chip}`,
      }}>Mag-sign in</div>

      <div style={{ padding: '40px 20px 24px', flex: 1, display: 'flex', flexDirection: 'column' }}>
        <div style={{
          fontFamily: JW.font, fontWeight: 700, fontSize: 26,
          color: JW.black, lineHeight: 1.22,
        }}>Ano ang iyong numero?</div>
        <div style={{ height: 8 }} />
        <div style={{
          fontFamily: JW.font, fontWeight: 400, fontSize: 14,
          color: JW.body, lineHeight: 1.5,
        }}>Padadalhan ka namin ng verification code.</div>

        <div style={{ height: 32 }} />

        {/* phone input */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          border: `1px solid ${JW.black}`, borderRadius: 12,
          padding: '14px 16px', height: 56,
        }}>
          <div style={{
            width: 22, height: 14, borderRadius: 2, overflow: 'hidden', position: 'relative',
            border: '1px solid rgba(0,0,0,0.1)', flexShrink: 0,
          }}>
            <div style={{ position: 'absolute', inset: 0, background: '#0038A8' }} />
            <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: '50%', background: '#CE1126' }} />
            <div style={{ position: 'absolute', top: 0, bottom: 0, left: 0, width: 0, height: 0,
              borderTop: '7px solid transparent', borderBottom: '7px solid transparent',
              borderLeft: '12px solid #fff' }} />
          </div>
          <span style={{
            fontFamily: JW.font, fontWeight: 500, fontSize: 16, color: JW.body,
          }}>+63</span>
          <div style={{ width: 1, height: 22, background: JW.chip }} />
          <input
            placeholder="9XX XXX XXXX"
            style={{
              flex: 1, border: 'none', outline: 'none',
              fontFamily: JW.font, fontWeight: 400, fontSize: 16, color: JW.black,
              background: 'transparent',
            }}
          />
        </div>

        <div style={{ height: 16 }} />
        <JWPill fullWidth>Humingi ng Code</JWPill>

        <div style={{ height: 24 }} />
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ flex: 1, height: 1, background: JW.chip }} />
          <span style={{ fontFamily: JW.font, fontSize: 14, color: JW.body }}>o</span>
          <div style={{ flex: 1, height: 1, background: JW.chip }} />
        </div>
        <div style={{ height: 24 }} />

        <div style={{ flex: 1 }} />

        <div style={{
          fontFamily: JW.font, fontWeight: 400, fontSize: 12,
          color: JW.muted, textAlign: 'center', lineHeight: 1.5,
        }}>
          Sa pag-sign in, sumasang-ayon ka sa aming{' '}
          <span style={{ color: JW.black, textDecoration: 'underline' }}>Terms</span>
          {' '}at{' '}
          <span style={{ color: JW.black, textDecoration: 'underline' }}>Privacy Policy</span>.
        </div>
      </div>
    </div>
  );
}

function OtpVerify() {
  const filled = [3, 8, 1]; // first 3 boxes filled
  return (
    <div style={{
      width: '100%', height: '100%', background: JW.white,
      display: 'flex', flexDirection: 'column',
    }}>
      <div style={{
        height: 56, display: 'flex', alignItems: 'center', padding: '0 16px',
        borderBottom: `1px solid ${JW.chip}`,
      }}>
        <button style={{
          width: 44, height: 44, border: 'none', background: 'transparent',
          display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
        }}>
          <svg width="10" height="18" viewBox="0 0 10 18" fill="none">
            <path d="M9 1L1 9l8 8" stroke={JW.black} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
        <div style={{
          flex: 1, textAlign: 'center', marginRight: 44,
          fontFamily: JW.font, fontWeight: 700, fontSize: 17,
        }}>I-verify</div>
      </div>

      <div style={{ padding: '40px 20px', flex: 1, display: 'flex', flexDirection: 'column' }}>
        <div style={{
          fontFamily: JW.font, fontWeight: 700, fontSize: 26, lineHeight: 1.22,
        }}>I-enter ang code</div>
        <div style={{ height: 8 }} />
        <div style={{
          fontFamily: JW.font, fontWeight: 400, fontSize: 14, color: JW.body, lineHeight: 1.5,
        }}>
          Ipinadala sa +63 917 555 4231{' '}
          <span style={{ color: JW.black, fontWeight: 500, textDecoration: 'underline' }}>Baguhin</span>
        </div>

        <div style={{ height: 32 }} />

        {/* OTP boxes */}
        <div style={{ display: 'flex', gap: 8, justifyContent: 'space-between' }}>
          {[0, 1, 2, 3, 4, 5].map(i => {
            const hasVal = i < filled.length;
            const isCursor = i === filled.length;
            return (
              <div key={i} style={{
                width: 48, height: 56, borderRadius: 8,
                background: hasVal ? JW.black : JW.chip,
                border: isCursor ? `2px solid ${JW.black}` : 'none',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontFamily: JW.font, fontWeight: 700, fontSize: 24,
                color: hasVal ? JW.white : JW.black,
                background: hasVal ? JW.black : (isCursor ? JW.white : JW.chip),
              }}>
                {hasVal ? filled[i] : (isCursor ? <span style={{
                  width: 2, height: 24, background: JW.black,
                  animation: 'jwDot 1s infinite',
                }} /> : '')}
              </div>
            );
          })}
        </div>

        <div style={{ height: 28 }} />
        <div style={{
          textAlign: 'center', fontFamily: JW.font, fontSize: 14, color: JW.muted,
        }}>Muling humingi ng code (00:45)</div>

        <div style={{ flex: 1 }} />
      </div>
    </div>
  );
}

Object.assign(window, { OtpEntry, OtpVerify });
