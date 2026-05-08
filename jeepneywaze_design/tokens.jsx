// JeepneyWaze design tokens
const JW = {
  // core
  black: '#000000',
  white: '#FFFFFF',
  body: '#4B4B4B',
  muted: '#AFAFAF',
  chip: '#EFEFEF',
  hover: '#E2E2E2',
  // accent
  yellow: '#F5C400',
  yellowDark: '#C49A00',
  yellowGlow: 'rgba(245,196,0,0.20)',
  // status
  red: '#E53935',
  green: '#2E7D32',
  orange: '#F57C00',
  // shadows
  shadowLight: 'rgba(0,0,0,0.12) 0px 4px 16px',
  shadowMed: 'rgba(0,0,0,0.16) 0px 4px 16px',
  shadowBeacon: 'rgba(245,196,0,0.30) 0px 0px 12px',
  font: 'Inter, system-ui, -apple-system, sans-serif',
};

// Inject Inter + global styles
if (typeof document !== 'undefined' && !document.getElementById('jw-styles')) {
  const link = document.createElement('link');
  link.rel = 'stylesheet';
  link.href = 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap';
  document.head.appendChild(link);

  const s = document.createElement('style');
  s.id = 'jw-styles';
  s.textContent = `
    .jw * { box-sizing: border-box; }
    .jw { font-family: ${JW.font}; color: ${JW.black}; -webkit-font-smoothing: antialiased; }
    @keyframes jwPulse {
      0% { transform: scale(1); opacity: 0.7; }
      100% { transform: scale(2.1); opacity: 0; }
    }
    @keyframes jwDot {
      0%, 80%, 100% { opacity: 0.3; transform: scale(0.85); }
      40% { opacity: 1; transform: scale(1); }
    }
    @keyframes jwShimmer {
      0% { background-position: -200px 0; }
      100% { background-position: 200px 0; }
    }
    .jw-skeleton {
      background: linear-gradient(90deg, ${JW.chip} 0%, #f7f7f7 50%, ${JW.chip} 100%);
      background-size: 400px 100%;
      animation: jwShimmer 1.4s infinite;
    }
  `;
  document.head.appendChild(s);
}

// ── Reusable bits ─────────────────────────────────────────────
function JWPill({ children, bg = JW.black, color = JW.white, weight = 500, size = 14, padding = '14px 24px', onClick, style = {}, fullWidth = false, border }) {
  return (
    <button onClick={onClick} style={{
      background: bg, color, border: border || 'none',
      borderRadius: 999, padding, minHeight: 48,
      fontFamily: JW.font, fontWeight: weight, fontSize: size,
      cursor: 'pointer', width: fullWidth ? '100%' : undefined,
      letterSpacing: 0, ...style,
    }}>{children}</button>
  );
}

function JWChip({ active, children, onClick }) {
  return (
    <button onClick={onClick} style={{
      background: active ? JW.black : JW.chip,
      color: active ? JW.white : JW.black,
      border: 'none', borderRadius: 999,
      padding: '9px 14px', fontFamily: JW.font,
      fontWeight: 500, fontSize: 13, cursor: 'pointer',
      whiteSpace: 'nowrap', flexShrink: 0,
    }}>{children}</button>
  );
}

function JWBadge({ kind, label }) {
  const map = {
    siksikan: { bg: JW.red, text: 'SIKSIKAN' },
    katamtaman: { bg: JW.orange, text: 'KATAMTAMAN' },
    malwag: { bg: JW.green, text: 'MALWAG' },
  };
  const d = map[kind];
  return (
    <span style={{
      background: d.bg, color: JW.white,
      fontWeight: 700, fontSize: 10, letterSpacing: 0.4,
      padding: '4px 8px', borderRadius: 999,
      fontFamily: JW.font, display: 'inline-block',
    }}>{label || d.text}</span>
  );
}

function JWPlaceholder({ label, height = 200, dark = false }) {
  // Striped illustration placeholder
  const stripeColor = dark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.04)';
  return (
    <div style={{
      width: '100%', height,
      background: `repeating-linear-gradient(45deg, ${dark ? '#1a1a1a' : '#f5f3ee'} 0 12px, ${dark ? '#222' : '#ece9e1'} 12px 24px)`,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      position: 'relative', overflow: 'hidden',
    }}>
      <div style={{
        background: dark ? 'rgba(0,0,0,0.7)' : 'rgba(255,255,255,0.92)',
        padding: '6px 10px', borderRadius: 4,
        fontFamily: 'JetBrains Mono, ui-monospace, monospace',
        fontSize: 10, color: dark ? JW.white : JW.body,
        letterSpacing: 0.2, textTransform: 'lowercase',
        border: `1px solid ${dark ? 'rgba(255,255,255,0.15)' : 'rgba(0,0,0,0.1)'}`,
      }}>illustration · {label}</div>
    </div>
  );
}

// Jeepney glyph (simple silhouette — original abstract)
function JeepneyGlyph({ size = 24, color = '#000' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M2 14 L2 10 L4 7 L9 6.5 L18 7 L21 9 L22 13 L22 16 L19 16 L19 17.5 A1.5 1.5 0 0 1 16 17.5 L16 16 L8 16 L8 17.5 A1.5 1.5 0 0 1 5 17.5 L5 16 L2 16 Z" fill={color}/>
      <rect x="5" y="9" width="3" height="3" fill="#fff" opacity="0.85"/>
      <rect x="9" y="9" width="3" height="3" fill="#fff" opacity="0.85"/>
      <rect x="13" y="9" width="3" height="3" fill="#fff" opacity="0.85"/>
      <circle cx="6.5" cy="17.5" r="1.5" fill="#000"/>
      <circle cx="17.5" cy="17.5" r="1.5" fill="#000"/>
    </svg>
  );
}

// Beacon marker
function JWBeacon({ stale = false, size = 44 }) {
  return (
    <div style={{
      position: 'relative', width: size, height: size,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      {!stale && (
        <div style={{
          position: 'absolute', inset: 0, borderRadius: 12,
          background: JW.yellow,
          animation: 'jwPulse 2s ease-out infinite',
        }} />
      )}
      <div style={{
        width: size, height: size, borderRadius: 12,
        background: stale ? JW.muted : JW.yellow,
        border: `2px solid ${JW.black}`,
        boxShadow: stale ? 'none' : JW.shadowBeacon,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        position: 'relative', zIndex: 2,
      }}>
        <JeepneyGlyph size={size * 0.55} color={JW.black} />
      </div>
    </div>
  );
}

// ETA bubble
function JWEtaBubble({ children }) {
  return (
    <div style={{
      background: JW.black, color: JW.white,
      fontFamily: JW.font, fontWeight: 700, fontSize: 11,
      padding: '3px 8px', borderRadius: 999,
      whiteSpace: 'nowrap',
    }}>{children}</div>
  );
}

// Shield/guardian icon
function JWShield({ size = 16, color = '#000' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
      <path d="M8 1 L13.5 3 L13.5 7.5 C13.5 11 11 13.5 8 14.8 C5 13.5 2.5 11 2.5 7.5 L2.5 3 Z" fill={color}/>
      <path d="M5.5 7.8 L7.3 9.5 L10.5 6" stroke="#F5C400" strokeWidth="1.4" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

Object.assign(window, { JW, JWPill, JWChip, JWBadge, JWPlaceholder, JeepneyGlyph, JWBeacon, JWEtaBubble, JWShield });
