// Splash + Onboarding screens

function SplashScreen() {
  return (
    <div style={{
      width: '100%', height: '100%', background: JW.black,
      display: 'flex', flexDirection: 'column', alignItems: 'center',
      justifyContent: 'center', position: 'relative',
    }}>
      <div style={{
        width: 80, height: 80, borderRadius: 18,
        background: JW.yellow, display: 'flex',
        alignItems: 'center', justifyContent: 'center',
        boxShadow: '0 0 60px rgba(245,196,0,0.35)',
      }}>
        <JeepneyGlyph size={50} color={JW.black} />
      </div>
      <div style={{ height: 16 }} />
      <div style={{
        fontFamily: JW.font, fontWeight: 700, fontSize: 28,
        color: JW.white, letterSpacing: -0.5,
      }}>JeepneyWaze</div>
      <div style={{ height: 8 }} />
      <div style={{
        fontFamily: JW.font, fontWeight: 400, fontSize: 14,
        color: JW.muted,
      }}>Alam mo na. Sumakay na.</div>

      {/* loading dots */}
      <div style={{
        position: 'absolute', bottom: 60, display: 'flex', gap: 8,
      }}>
        {[0, 1, 2].map(i => (
          <div key={i} style={{
            width: 8, height: 8, borderRadius: 999,
            background: JW.yellow,
            animation: `jwDot 1.2s ease-in-out ${i * 0.16}s infinite`,
          }} />
        ))}
      </div>
    </div>
  );
}

function OnboardingSlide({ chip, headline, body, ctaLabel, ctaYellow, dotIndex, illustration, extra }) {
  return (
    <div style={{
      width: '100%', height: '100%', background: JW.white,
      display: 'flex', flexDirection: 'column',
    }}>
      <div style={{ height: '52%', position: 'relative' }}>
        {illustration}
      </div>
      <div style={{ flex: 1, padding: '24px 20px 28px', display: 'flex', flexDirection: 'column' }}>
        <div style={{
          alignSelf: 'flex-start',
          background: JW.black, color: JW.white,
          padding: '5px 10px', borderRadius: 999,
          fontFamily: JW.font, fontWeight: 700, fontSize: 10, letterSpacing: 0.6,
        }}>{chip}</div>
        <div style={{ height: 14 }} />
        <div style={{
          fontFamily: JW.font, fontWeight: 700, fontSize: 26,
          lineHeight: 1.22, color: JW.black, textWrap: 'balance',
        }}>{headline}</div>
        <div style={{ height: 12 }} />
        <div style={{
          fontFamily: JW.font, fontWeight: 400, fontSize: 14,
          lineHeight: 1.55, color: JW.body,
        }}>{body}</div>
        {extra && <><div style={{ height: 14 }} />{extra}</>}
        <div style={{ flex: 1 }} />

        {/* progress dots */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 16 }}>
          {[0, 1, 2].map(i => (
            <div key={i} style={{
              width: i === dotIndex ? 24 : 8,
              height: 8, borderRadius: 999,
              background: i === dotIndex ? JW.black : JW.chip,
              transition: 'all 0.25s',
            }} />
          ))}
        </div>
        <JWPill bg={ctaYellow ? JW.yellow : JW.black}
                color={ctaYellow ? JW.black : JW.white}
                weight={ctaYellow ? 700 : 500}
                fullWidth>{ctaLabel}</JWPill>
      </div>
    </div>
  );
}

// Custom illustrations using placeholder + accent shapes
function Illust1() {
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: '#f5f3ee', overflow: 'hidden',
    }}>
      <JWPlaceholder label="EDSA · birds-eye beacon cluster" height="100%" />
      {/* overlaid beacon decoration */}
      <div style={{
        position: 'absolute', top: '38%', left: '50%',
        transform: 'translate(-50%, -50%)',
      }}>
        <div style={{
          width: 64, height: 64, borderRadius: 18,
          background: JW.yellow, border: `3px solid ${JW.black}`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 8px 24px rgba(245,196,0,0.5)',
        }}>
          <JeepneyGlyph size={36} color={JW.black} />
        </div>
        {/* radiating phone dots */}
        {[0, 60, 120, 180, 240, 300].map(deg => {
          const r = 70;
          const x = Math.cos(deg * Math.PI / 180) * r;
          const y = Math.sin(deg * Math.PI / 180) * r;
          return (
            <div key={deg} style={{
              position: 'absolute', top: '50%', left: '50%',
              transform: `translate(${x}px, ${y}px) translate(-50%, -50%)`,
              width: 14, height: 18, borderRadius: 3,
              background: JW.black,
              boxShadow: `0 0 12px ${JW.yellow}`,
            }}>
              <div style={{
                position: 'absolute', inset: 2, borderRadius: 1,
                background: JW.yellow,
              }} />
            </div>
          );
        })}
      </div>
    </div>
  );
}

function Illust2() {
  return (
    <div style={{ width: '100%', height: '100%', position: 'relative' }}>
      <JWPlaceholder label="commuter inside jeepney · POV" height="100%" />
      <div style={{
        position: 'absolute', top: 22, left: '50%', transform: 'translateX(-50%)',
        display: 'flex', gap: 6,
      }}>
        <JWBadge kind="siksikan" />
        <JWBadge kind="malwag" />
      </div>
    </div>
  );
}

function Illust3() {
  return (
    <div style={{ width: '100%', height: '100%', position: 'relative', background: '#1a1a1a' }}>
      <JWPlaceholder label="Manila skyline at dusk · guardian badge" height="100%" dark />
      <div style={{
        position: 'absolute', top: '40%', left: '50%',
        transform: 'translate(-50%, -50%)',
        width: 88, height: 88, borderRadius: 999,
        background: JW.yellow,
        boxShadow: '0 0 50px rgba(245,196,0,0.6)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <JWShield size={44} color={JW.black} />
      </div>
    </div>
  );
}

function Onb1() {
  return <OnboardingSlide
    chip="HOW IT WORKS"
    headline="Nakikita namin ang jeepney kahit walang driver app."
    body="Ang iyong GPS ang nagpapakita kung nasaan ang jeepney. Walang hardware. Libre."
    ctaLabel="Sunod"
    dotIndex={0}
    illustration={<Illust1 />}
  />;
}

function Onb2() {
  return <OnboardingSlide
    chip="SIKSIKAN O MALWAG"
    headline="Sabihin sa iba kung puno o may puwang."
    body="Isang tap lang para mag-report ng crowding. Lahat nakikinabang kapag nagbahagi tayo."
    ctaLabel="Sunod"
    dotIndex={1}
    illustration={<Illust2 />}
  />;
}

function Onb3() {
  return <OnboardingSlide
    chip="ROUTE GUARDIAN"
    headline="Mag-earn ng Guardian Points sa tuwing tutulong ka."
    body="Ang pinaka-aktibong commuters ang nagiging Route Guardians ng kanilang linya."
    ctaLabel="Magsimula na"
    ctaYellow
    dotIndex={2}
    illustration={<Illust3 />}
  />;
}

Object.assign(window, { SplashScreen, Onb1, Onb2, Onb3 });
